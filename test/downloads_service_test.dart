// DownloadService transfers: the happy path, resume, verification, adhkar
// scans and progress writes — against a fake HTTP client and memory store.
// Controls (pause/cancel/queue) are in downloads_service_control_test.dart,
// failures in downloads_service_failure_test.dart.
import 'dart:convert';

import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/download_harness.dart';

/// Counts [setProgress] calls.
class _CountingRepo extends DownloadRepository {
  _CountingRepo(super.db);
  int progressWrites = 0;

  @override
  Future<void> setProgress(String fileId, int bytesDone, {int? bytesTotal}) {
    progressWrites++;
    return super.setProgress(fileId, bytesDone, bytesTotal: bytesTotal);
  }
}

void main() {
  final h = DownloadHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  test('happy path: done, final bytes, no .part, onFileDone once', () async {
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.done);
    expect(item.bytesDone, 8);
    expect(item.relativePath, fatihaFinal);
    expect(h.files.bytesOf(fatihaFinal), fatihaBody);
    expect(await h.files.exists(fatihaPart), isFalse);
    expect(h.done.length, 1);
    expect(h.done.single.$1.id, 'test-reciter');
    expect(h.done.single.$2.id, fatiha);
    expect(h.done.single.$3, fatihaFinal);
    expect(h.server.rangeOf(fatihaUrl), isNull);
  });

  test('an existing 4-byte .part resumes with Range: bytes=4-', () async {
    h.files.files[fatihaPart] = [1, 2, 3, 4];
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    expect(h.server.rangeOf(fatihaUrl), 'bytes=4-');
    expect(h.files.bytesOf(fatihaFinal), fatihaBody);
    expect((await h.row(fatiha)).status, DownloadStatus.done);
  });

  test('server answers 200 to a Range request: restart from zero', () async {
    h.files.files[fatihaPart] = [9, 9, 9, 9];
    h.server.ignoreRange = true;
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    expect(h.server.rangeOf(fatihaUrl), 'bytes=4-');
    expect(h.files.bytesOf(fatihaFinal), fatihaBody);
    expect((await h.row(fatiha)).status, DownloadStatus.done);
  });

  test('without a Content-Length, a wrong size is caught at the end', () async {
    h.server.sendLength = false;
    h.server.bodies[fatihaUrl] = [1, 2, 3, 4, 5, 6];
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('size'));
    expect(await h.files.exists(fatihaFinal), isFalse);
    expect(await h.files.exists(fatihaPart), isFalse);
    expect(h.done, isEmpty);
  });

  test(
    'checksum match: done; checksum mismatch: failed, no final file',
    () async {
      await h.service.enqueueFile(ikhlaas);
      await h.service.whenIdle();
      expect((await h.row(ikhlaas)).status, DownloadStatus.done);

      await h.service.deleteFile(ikhlaas);
      h.server.bodies['/audio/112.mp3'] = 'tampered'.codeUnits;
      await h.service.enqueueFile(ikhlaas);
      await h.service.whenIdle();
      final item = await h.row(ikhlaas);
      expect(item.status, DownloadStatus.failed);
      expect(item.error, contains('checksum'));
      expect(await h.files.exists('audio/test-reciter/112.mp3'), isFalse);
      expect(await h.files.exists('audio/test-reciter/112.mp3.part'), isFalse);
    },
  );

  test('an adhkarScans file downloads like any other', () async {
    await h.service.enqueueFile('test-scans-booklet');
    await h.service.whenIdle();
    expect(
      h.files.bytesOf('audio/test-scans/evening.pdf'),
      utf8.encode('%PDF-1.4'),
    );
    expect(h.done.single.$1.id, 'test-scans');
  });

  test('a final file already present with the catalog size is marked done '
      'without a request', () async {
    h.files.files[fatihaFinal] = List.of(fatihaBody);
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.done);
    expect(item.bytesDone, 8);
    expect(h.server.requests, isEmpty);
    expect(h.done.single.$2.id, fatiha);
  });

  group('progress writes are rate-limited in time', () {
    late _CountingRepo counting;
    setUp(() {
      counting = _CountingRepo(h.db);
      h.server.bodies['/audio/002.mp3'] = List.filled(300, 2); // 100 chunks
    });

    Future<int> download(Duration interval) async {
      await h.replaceService(
        () => h.newService(repository: counting, progressInterval: interval),
      );
      await h.service.enqueueFile('test-reciter-002');
      await h.service.whenIdle();
      expect((await h.row('test-reciter-002')).bytesDone, 300);
      return counting.progressWrites;
    }

    test('a long interval: no writes per chunk, only start and end', () async {
      expect(await download(const Duration(hours: 1)), lessThanOrEqualTo(4));
    });

    test('a zero interval: a write per chunk', () async {
      expect(await download(Duration.zero), greaterThanOrEqualTo(100));
    });
  });
}
