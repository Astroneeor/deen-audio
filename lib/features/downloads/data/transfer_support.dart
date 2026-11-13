import 'dart:developer' as developer;

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../../core/storage/file_store.dart';
import 'download_models.dart';
import 'download_repository.dart';

/// A transfer failure with the reason shown to the user.
class TransferFailure implements Exception {
  TransferFailure(this.reason);
  final String reason;

  @override
  String toString() => reason;
}

/// Raised inside the body stream when no data arrived for too long.
class StalledError implements Exception {
  const StalledError();
}

const stalledReason = 'Connection stalled. Resume to continue.';
const outOfDateReason = 'The catalog is out of date for this file';

/// The `first` position of a 206's `Content-Range: bytes first-last/total`,
/// or null when the header is missing or malformed.
int? contentRangeStart(http.BaseResponse res) {
  final m = RegExp(
    r'^bytes (\d+)-\d+/',
  ).firstMatch(res.headers['content-range'] ?? '');
  return m == null ? null : int.parse(m.group(1)!);
}

/// The full file size the server says it has: Content-Length for a 200; for
/// a 206 the `/total` of Content-Range, else [offset] + Content-Length.
int? serverTotal(http.BaseResponse res, int offset) {
  if (res.statusCode == 206) {
    final total = RegExp(
      r'/(\d+)$',
    ).firstMatch(res.headers['content-range'] ?? '')?.group(1);
    if (total != null) return int.parse(total);
  }
  final length = res.contentLength;
  return length == null ? null : offset + length;
}

/// Hex digest of [bytes] with [algo] (sha256 | sha1 | md5).
Future<String> digestOf(String algo, Stream<List<int>> bytes) async {
  final Hash hash = switch (algo) {
    'sha256' => sha256,
    'sha1' => sha1,
    'md5' => md5,
    _ => throw TransferFailure('Unsupported checksum algorithm "$algo"'),
  };
  return (await hash.bind(bytes).first).toString();
}

/// Closes [sink], ignoring errors (used when already failing).
Future<void> closeQuietly(IOSinkLike sink) async {
  try {
    await sink.close();
  } catch (_) {
    // The original error is the one reported.
  }
}

/// Drops an unread response body.
Future<void> discardBody(http.StreamedResponse res) async {
  try {
    await res.stream.listen(null).cancel();
  } catch (_) {
    // Nothing to clean up.
  }
}

/// Marks [fileId] failed with [reason], retrying a failing database write a
/// few times; never throws, so a row is not left `running` by one bad write.
Future<void> markFailed(
  DownloadRepository repo,
  String fileId,
  String reason,
) async {
  for (var attempt = 1; attempt <= 3; attempt++) {
    try {
      await repo.setStatus(fileId, DownloadStatus.failed, error: reason);
      return;
    } catch (e, st) {
      developer.log(
        'Could not mark $fileId failed (attempt $attempt)',
        name: 'downloads',
        error: e,
        stackTrace: st,
      );
    }
  }
}
