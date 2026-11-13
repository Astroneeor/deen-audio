// DownloadService: transfers, resume, pause/cancel/delete, failures,
// concurrency and restore — against a fake HTTP client and memory store.
import 'dart:io';

import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'support/download_harness.dart';

void main() {
  final h = DownloadHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  Future<DownloadItem> row(String id) async => (await h.repo.get(id))!;

  test('happy path: done, final bytes, no .part, onFileDone once', () async {
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await row(fatiha);
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
    expect((await row(fatiha)).status, DownloadStatus.done);
  });

  test('server answers 200 to a Range request: restart from zero', () async {
    h.files.files[fatihaPart] = [9, 9, 9, 9];
    h.server.ignoreRange = true;
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    expect(h.server.rangeOf(fatihaUrl), 'bytes=4-');
    expect(h.files.bytesOf(fatihaFinal), fatihaBody);
    expect((await row(fatiha)).status, DownloadStatus.done);
  });

  Future<void> startHeld() async {
    h.server.hold = true;
    await h.service.enqueueFile(fatiha);
    await pumpEventQueue();
    h.server.held[fatihaUrl]!.add([1, 2, 3]);
    await pumpEventQueue();
  }

  test('pause mid-stream keeps the .part and status paused', () async {
    await startHeld();
    expect((await row(fatiha)).status, DownloadStatus.running);

    await h.service.pause(fatiha);
    final item = await row(fatiha);
    expect(item.status, DownloadStatus.paused);
    expect(item.bytesDone, 3);
    expect(h.files.bytesOf(fatihaPart), [1, 2, 3]);
    expect(await h.files.exists(fatihaFinal), isFalse);
    expect(h.server.inFlight, 0);

    // Resuming continues from byte 3.
    h.server.hold = false;
    await h.service.resume(fatiha);
    await h.service.whenIdle();
    expect(h.server.rangeOf(fatihaUrl), 'bytes=3-');
    expect(h.files.bytesOf(fatihaFinal), fatihaBody);
  });

  test('cancel removes the .part and the row', () async {
    await startHeld();
    await h.service.cancel(fatiha);
    expect(await h.files.exists(fatihaPart), isFalse);
    expect(await h.repo.get(fatiha), isNull);
    expect(h.done, isEmpty);
  });

  test('size mismatch: failed, no final file', () async {
    h.server.bodies[fatihaUrl] = [1, 2, 3, 4, 5, 6];
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await row(fatiha);
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
      expect((await row(ikhlaas)).status, DownloadStatus.done);

      await h.service.deleteFile(ikhlaas);
      h.server.bodies['/audio/112.mp3'] = 'tampered'.codeUnits;
      await h.service.enqueueFile(ikhlaas);
      await h.service.whenIdle();
      final item = await row(ikhlaas);
      expect(item.status, DownloadStatus.failed);
      expect(item.error, contains('checksum'));
      expect(await h.files.exists('audio/test-reciter/112.mp3'), isFalse);
      expect(await h.files.exists('audio/test-reciter/112.mp3.part'), isFalse);
    },
  );

  test('404: failed with a reason containing 404', () async {
    h.server.statusFor['/audio/113.mp3'] = 404;
    await h.service.enqueueFile('test-reciter-113');
    await h.service.whenIdle();
    final item = await row('test-reciter-113');
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('404'));
    expect(await h.files.exists('audio/test-reciter/113.mp3'), isFalse);
  });

  test('offline: failed with a readable reason', () async {
    h.server.connectError = http.ClientException('Failed host lookup');
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();
    final item = await row(fatiha);
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('Could not reach'));
  });

  test(
    'a write error from the store: failed, readable, no final file',
    () async {
      h.files.writeError = const FileSystemException('No space left on device');
      await h.service.enqueueFile(fatiha);
      await h.service.whenIdle();
      final item = await row(fatiha);
      expect(item.status, DownloadStatus.failed);
      expect(item.error, contains('Could not save'));
      expect(item.error, contains('No space left on device'));
      // The chunk is not counted: the failed flush means it was not written.
      expect(item.bytesDone, 0);
      expect(await h.files.exists(fatihaFinal), isFalse);
      expect(h.done, isEmpty);
    },
  );

  test('five files enqueued never exceed two simultaneous requests', () async {
    h.server.hold = true;
    await h.service.enqueuePack('test-reciter');
    await pumpEventQueue();
    expect(h.server.requests.length, 2);
    expect(h.server.inFlight, 2);

    while (h.server.held.isNotEmpty) {
      final path = h.server.held.keys.first;
      final body = h.server.held.remove(path)!;
      body.add(h.server.bodies[path]!);
      await body.close();
      await pumpEventQueue();
      expect(h.server.inFlight, lessThanOrEqualTo(2));
    }
    await h.service.whenIdle();
    expect(h.server.maxInFlight, 2);
    expect(h.server.requests.length, 5);
    final items = await h.repo.getAll();
    expect(items.map((i) => i.status).toSet(), {DownloadStatus.done});
    expect(h.done.length, 5);
  });

  test('restore() after a crash: running becomes paused, no request', () async {
    await startHeld();
    // Simulate a crash: drop the service without pausing, start a new one.
    final requestsBefore = h.server.requests.length;
    final crashed = h.service;
    h.service = h.newService();
    await h.service.restore();
    await pumpEventQueue();

    expect((await row(fatiha)).status, DownloadStatus.paused);
    expect(h.server.requests.length, requestsBefore);
    expect(h.files.bytesOf(fatihaPart), [1, 2, 3]);
    await crashed.dispose();
  });

  test('deleteFile removes the file and row and calls onFileRemoved', () async {
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();
    expect(await h.service.usedBytes(), 8);

    await h.service.deleteFile(fatiha);
    expect(await h.files.exists(fatihaFinal), isFalse);
    expect(await h.repo.get(fatiha), isNull);
    expect(h.removed.single.id, fatiha);
    expect(await h.service.usedBytes(), 0);
  });

  test('pausePack, resumePack, deletePack', () async {
    h.server.hold = true;
    await h.service.enqueuePack('test-reciter');
    await pumpEventQueue();
    await h.service.pausePack('test-reciter');
    final paused = await h.repo.getAll();
    expect(paused.length, 5);
    expect(paused.map((i) => i.status).toSet(), {DownloadStatus.paused});

    h.server.hold = false;
    await h.service.resumePack('test-reciter');
    await h.service.whenIdle();
    expect((await h.repo.getAll()).map((i) => i.status).toSet(), {
      DownloadStatus.done,
    });

    await h.service.deletePack('test-reciter');
    expect(await h.repo.getAll(), isEmpty);
    expect(await h.files.usedBytes('audio/test-reciter'), 0);
    expect(h.removed.length, 5);
  });

  test('an adhkarScans file downloads like any other', () async {
    await h.service.enqueueFile('test-scans-booklet');
    await h.service.whenIdle();
    expect(
      h.files.bytesOf('audio/test-scans/evening.pdf'),
      '%PDF-1.4'.codeUnits,
    );
    expect(h.done.single.$1.id, 'test-scans');
  });

  test(
    'enqueueing an unknown id throws; a done file is not re-fetched',
    () async {
      expect(() => h.service.enqueueFile('nope'), throwsArgumentError);
      await h.service.enqueueFile(fatiha);
      await h.service.whenIdle();
      await h.service.enqueueFile(fatiha);
      await h.service.whenIdle();
      expect(h.server.requests.length, 1);
    },
  );
}
