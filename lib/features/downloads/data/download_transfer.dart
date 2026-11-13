import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../../core/storage/file_store.dart';
import 'catalog.dart';
import 'download_models.dart';
import 'download_repository.dart';
import 'transfer_support.dart';

/// How a [DownloadTransfer] ended.
enum TransferOutcome { done, failed, aborted }

/// Downloads one catalog file into `<relativePath>.part` (resuming an
/// existing part with a Range request), verifies size and checksum, then
/// renames it to [relativePath]. Writes status and progress to [repo]:
/// `running` at start, then `done` or `failed`; an [abort] (pause, cancel,
/// delete) leaves the status to the caller and keeps the part.
class DownloadTransfer {
  DownloadTransfer({
    required this.client,
    required this.files,
    required this.repo,
    required this.file,
    required this.relativePath,
    this.stallTimeout = const Duration(seconds: 30),
    this.progressInterval = const Duration(milliseconds: 500),
  });

  final http.Client client;
  final FileStore files;
  final DownloadRepository repo;
  final CatalogFile file;
  final String relativePath;

  /// How long the server may send nothing (headers or body) before the
  /// transfer fails as stalled.
  final Duration stallTimeout;

  /// Progress is written to the database at most this often (plus once at
  /// the end).
  final Duration progressInterval;

  final _abort = Completer<void>();

  String get partPath => '$relativePath.part';
  bool get aborted => _abort.isCompleted;

  /// Stops the transfer now, even while waiting for the server.
  void abort() {
    if (!_abort.isCompleted) _abort.complete();
  }

  /// Runs the transfer. Never throws: failures end as [TransferOutcome.failed]
  /// with the reason stored on the row (best effort).
  Future<TransferOutcome> run() async {
    try {
      await repo.setStatus(file.id, DownloadStatus.running);
      final outcome = await _download(mayRestart: true);
      if (outcome == TransferOutcome.done) {
        await repo.setStatus(file.id, DownloadStatus.done);
      }
      return outcome;
    } catch (e) {
      // After an abort the caller decides the status (e.g. paused).
      if (aborted) return TransferOutcome.aborted;
      await markFailed(
        repo,
        file.id,
        e is TransferFailure ? e.reason : 'Download failed: $e',
      );
      return TransferOutcome.failed;
    }
  }

  Future<TransferOutcome> _download({required bool mayRestart}) async {
    if (aborted) return TransferOutcome.aborted;
    var offset = await files.size(partPath);
    final request = http.Request('GET', file.url);
    if (offset > 0) request.headers['Range'] = 'bytes=$offset-';
    if (aborted) return TransferOutcome.aborted;
    final res = await _send(request);
    if (res == null) return TransferOutcome.aborted;

    final code = res.statusCode;
    if (code == 416 && offset > 0) {
      // The part may already be complete; otherwise start again from zero.
      await discardBody(res);
      if (offset == file.sizeBytes) return _finish(offset);
      await files.delete(partPath);
      if (mayRestart) return _download(mayRestart: false);
      throw TransferFailure('Server refused to resume (416). Try again.');
    }
    if (code == 206) {
      if (contentRangeStart(res) != offset) {
        await discardBody(res);
        await files.delete(partPath);
        throw TransferFailure(
          'Server resumed at the wrong position. '
          'Try again.',
        );
      }
    } else if (code == 200) {
      if (offset > 0) await files.delete(partPath); // Range ignored: restart.
      offset = 0;
    } else {
      await discardBody(res);
      final reason = res.reasonPhrase == null ? '' : ' ${res.reasonPhrase}';
      throw TransferFailure('Server returned $code$reason for ${file.url}');
    }

    final total = serverTotal(res, offset);
    final expected = file.sizeBytes;
    if (expected != null && total != null && total != expected) {
      await discardBody(res);
      await files.delete(partPath);
      throw TransferFailure(
        '$outOfDateReason (the server has $total bytes, '
        'the catalog says $expected). Nothing was downloaded.',
      );
    }
    await repo.setProgress(file.id, offset, bytesTotal: expected ?? total);
    final written = await _stream(res, offset);
    if (aborted) return TransferOutcome.aborted;
    if (total != null && written < total) {
      throw TransferFailure(
        'Download ended early ($written of $total '
        'bytes). Resume to continue.',
      );
    }
    return _finish(written);
  }

  /// Sends [request]; null if aborted before the answer arrived.
  Future<http.StreamedResponse?> _send(http.Request request) async {
    final sent = client.send(request);
    final http.StreamedResponse? res;
    try {
      res = await Future.any<http.StreamedResponse?>([
        sent,
        _abort.future.then((_) => null),
      ]).timeout(stallTimeout);
    } on TimeoutException {
      unawaited(sent.then(discardBody, onError: (Object _) {}));
      throw TransferFailure(stalledReason);
    } on http.ClientException catch (e) {
      throw TransferFailure('Could not reach ${file.url.host}: ${e.message}');
    } catch (e) {
      throw TransferFailure('Could not reach ${file.url.host}: $e');
    }
    if (res == null) {
      unawaited(sent.then(discardBody, onError: (Object _) {}));
      return null;
    }
    if (aborted) {
      await discardBody(res);
      return null;
    }
    return res;
  }

  /// Appends the body to the part; returns the part's size afterwards.
  Future<int> _stream(http.StreamedResponse res, int offset) async {
    var written = offset;
    final clock = Stopwatch()..start();
    var lastSave = Duration.zero;
    final sink = await _guardWrite(() => files.openAppend(partPath));
    final body = res.stream
        .timeout(
          stallTimeout,
          onTimeout: (s) {
            s.addError(const StalledError());
            s.close();
          },
        )
        .takeUntil(_abort.future.asStream());
    try {
      await for (final chunk in body) {
        // A real IOSink reports write errors only on flush/close, so a chunk
        // counts as written once the flush has succeeded.
        await _guardWrite(() async {
          sink.add(chunk);
          await sink.flush();
        });
        written += chunk.length;
        if (clock.elapsed - lastSave >= progressInterval) {
          await _guardDb(() => repo.setProgress(file.id, written));
          lastSave = clock.elapsed;
        }
      }
      await _guardWrite(sink.close);
    } catch (e) {
      await closeQuietly(sink);
      try {
        await repo.setProgress(file.id, written);
      } catch (_) {
        // Best effort; the original error is the one reported.
      }
      if (e is TransferFailure) rethrow;
      if (e is StalledError) throw TransferFailure(stalledReason);
      final message = e is http.ClientException ? e.message : '$e';
      throw TransferFailure('Connection lost: $message. Resume to continue.');
    }
    await repo.setProgress(file.id, written);
    return written;
  }

  /// Verifies the complete part and moves it into place.
  Future<TransferOutcome> _finish(int size) async {
    final expected = file.sizeBytes;
    if (expected != null && size != expected) {
      await files.delete(partPath);
      throw TransferFailure(
        'Downloaded size does not match the catalog '
        '(expected $expected bytes, got $size). The file was discarded.',
      );
    }
    final checksum = file.checksum;
    if (checksum != null &&
        await digestOf(file.checksumAlgo!, files.openRead(partPath)) !=
            checksum) {
      await files.delete(partPath);
      throw TransferFailure(
        'The file checksum does not match the catalog. '
        'The file was discarded.',
      );
    }
    await _guardWrite(() => files.rename(partPath, relativePath));
    await repo.setProgress(file.id, size, bytesTotal: size);
    return TransferOutcome.done;
  }

  Future<T> _guardWrite<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (e) {
      throw TransferFailure('Could not save the file: $e');
    }
  }

  Future<void> _guardDb(Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      throw TransferFailure('Download failed: $e');
    }
  }
}
