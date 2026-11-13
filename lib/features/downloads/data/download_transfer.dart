import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../../core/storage/file_store.dart';
import 'catalog.dart';
import 'download_models.dart';
import 'download_repository.dart';

/// How a [DownloadTransfer] ended.
enum TransferOutcome { done, failed, aborted }

/// A failure with the reason shown to the user.
class _Failure implements Exception {
  _Failure(this.reason);
  final String reason;
}

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
  });

  /// Progress is written to the database at most once per this many bytes.
  static const progressStep = 256 * 1024;

  final http.Client client;
  final FileStore files;
  final DownloadRepository repo;
  final CatalogFile file;
  final String relativePath;
  final _abort = Completer<void>();

  String get partPath => '$relativePath.part';
  bool get aborted => _abort.isCompleted;

  /// Stops the transfer at the next chunk (or before the request is sent).
  void abort() {
    if (!_abort.isCompleted) _abort.complete();
  }

  /// Runs the transfer. Never throws: failures end as [TransferOutcome.failed]
  /// with the reason stored on the row.
  Future<TransferOutcome> run() async {
    try {
      await repo.setStatus(file.id, DownloadStatus.running);
      final outcome = await _download(mayRestart: true);
      if (outcome == TransferOutcome.done) {
        await repo.setStatus(file.id, DownloadStatus.done);
      }
      return outcome;
    } on _Failure catch (f) {
      await repo.setStatus(file.id, DownloadStatus.failed, error: f.reason);
      return TransferOutcome.failed;
    } catch (e) {
      await repo.setStatus(
        file.id,
        DownloadStatus.failed,
        error: 'Download failed: $e',
      );
      return TransferOutcome.failed;
    }
  }

  Future<TransferOutcome> _download({required bool mayRestart}) async {
    if (aborted) return TransferOutcome.aborted;
    var offset = await files.size(partPath);
    final request = http.Request('GET', file.url);
    if (offset > 0) request.headers['Range'] = 'bytes=$offset-';

    final http.StreamedResponse res;
    try {
      res = await client.send(request);
    } on http.ClientException catch (e) {
      throw _Failure('Could not reach ${file.url.host}: ${e.message}');
    } catch (e) {
      throw _Failure('Could not reach ${file.url.host}: $e');
    }
    if (aborted) return _discard(res, TransferOutcome.aborted);

    final code = res.statusCode;
    if (code == 416 && offset > 0) {
      // The part may already be complete; otherwise start again from zero.
      if (offset == file.sizeBytes) {
        await _discard(res, null);
        return _finish(offset);
      }
      await _discard(res, null);
      await files.delete(partPath);
      if (mayRestart) return _download(mayRestart: false);
      throw _Failure('Server refused to resume (416). Try again.');
    }
    if (code == 206) {
      final start = RegExp(
        r'bytes (\d+)-',
      ).firstMatch(res.headers['content-range'] ?? '')?.group(1);
      if (start != null && int.parse(start) != offset) {
        await _discard(res, null);
        await files.delete(partPath);
        throw _Failure('Server resumed at the wrong position. Try again.');
      }
    } else if (code == 200) {
      if (offset > 0) await files.delete(partPath); // Range ignored: restart.
      offset = 0;
    } else {
      await _discard(res, null);
      final reason = res.reasonPhrase == null ? '' : ' ${res.reasonPhrase}';
      throw _Failure('Server returned $code$reason for ${file.url}');
    }

    final declared = res.contentLength == null
        ? null
        : offset + res.contentLength!;
    await repo.setProgress(
      file.id,
      offset,
      bytesTotal: file.sizeBytes ?? declared,
    );
    final written = await _stream(res, offset);
    if (aborted) return TransferOutcome.aborted;
    if (declared != null && written < declared) {
      throw _Failure(
        'Download ended early ($written of $declared bytes). '
        'Resume to continue.',
      );
    }
    return _finish(written);
  }

  /// Appends the body to the part; returns the part's size afterwards.
  Future<int> _stream(http.StreamedResponse res, int offset) async {
    var written = offset;
    var saved = offset;
    final sink = await _guardWrite(() => files.openAppend(partPath));
    try {
      await for (final chunk in res.stream.takeUntil(
        _abort.future.asStream(),
      )) {
        // A real IOSink reports write errors only on flush/close, so a chunk
        // counts as written once the flush has succeeded.
        await _guardWrite(() async {
          sink.add(chunk);
          await sink.flush();
        });
        written += chunk.length;
        if (written - saved >= progressStep) {
          await repo.setProgress(file.id, written);
          saved = written;
        }
      }
      await _guardWrite(sink.close);
    } on _Failure {
      await _closeQuietly(sink);
      await repo.setProgress(file.id, written);
      rethrow;
    } catch (e) {
      await _closeQuietly(sink);
      await repo.setProgress(file.id, written);
      final message = e is http.ClientException ? e.message : '$e';
      throw _Failure('Connection lost: $message. Resume to continue.');
    }
    await repo.setProgress(file.id, written);
    return written;
  }

  /// Verifies the complete part and moves it into place.
  Future<TransferOutcome> _finish(int size) async {
    final expected = file.sizeBytes;
    if (expected != null && size != expected) {
      await files.delete(partPath);
      throw _Failure(
        'Downloaded size does not match the catalog '
        '(expected $expected bytes, got $size). The file was discarded.',
      );
    }
    final checksum = file.checksum;
    if (checksum != null) {
      final digest = await _hash(
        file.checksumAlgo!,
      ).bind(files.openRead(partPath)).first;
      if (digest.toString() != checksum) {
        await files.delete(partPath);
        throw _Failure(
          'The file checksum does not match the catalog. '
          'The file was discarded.',
        );
      }
    }
    await _guardWrite(() => files.rename(partPath, relativePath));
    await repo.setProgress(file.id, size, bytesTotal: size);
    return TransferOutcome.done;
  }

  static Hash _hash(String algo) => switch (algo) {
    'sha256' => sha256,
    'sha1' => sha1,
    'md5' => md5,
    _ => throw _Failure('Unsupported checksum algorithm "$algo"'),
  };

  Future<T> _guardWrite<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (e) {
      throw _Failure('Could not save the file: $e');
    }
  }

  static Future<void> _closeQuietly(IOSinkLike sink) async {
    try {
      await sink.close();
    } catch (_) {
      // Already failing; the original error is the one reported.
    }
  }

  /// Drops an unread response body and returns [outcome].
  static Future<T> _discard<T>(http.StreamedResponse res, T outcome) async {
    try {
      await res.stream.listen(null).cancel();
    } catch (_) {
      // Nothing to clean up.
    }
    return outcome;
  }
}
