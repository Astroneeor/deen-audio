// DownloadService controls: pause, resume, cancel, delete, the two-at-a-time
// queue, restore after a crash, and races between them.
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/download_harness.dart';

void main() {
  final h = DownloadHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  test('pause mid-stream keeps the .part and status paused', () async {
    await h.startHeld();
    expect((await h.row(fatiha)).status, DownloadStatus.running);

    await h.service.pause(fatiha);
    final item = await h.row(fatiha);
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
    await h.startHeld();
    await h.service.cancel(fatiha);
    expect(await h.files.exists(fatihaPart), isFalse);
    expect(await h.repo.get(fatiha), isNull);
    expect(h.done, isEmpty);
  });

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
    await h.startHeld();
    // Simulate a crash: drop the service without pausing, start a new one.
    final requestsBefore = h.server.requests.length;
    final crashed = h.service;
    h.service = h.newService();
    await h.service.restore();
    await pumpEventQueue();

    expect((await h.row(fatiha)).status, DownloadStatus.paused);
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

  test('pause while the server never answers: completes, frees the slot '
      'for the next queued file', () async {
    await h.replaceService(() => h.newService(maxConcurrent: 1));
    h.server.neverAnswer.add(fatihaUrl);
    await h.service.enqueueFile(fatiha);
    await h.service.enqueueFile('test-reciter-113');
    await pumpEventQueue();
    expect(h.server.requests.length, 1);

    await h.service.pause(fatiha).timeout(const Duration(seconds: 5));
    await h.service.whenIdle().timeout(const Duration(seconds: 5));
    expect((await h.row(fatiha)).status, DownloadStatus.paused);
    expect((await h.row('test-reciter-113')).status, DownloadStatus.done);
  });

  test('cancel issued while enqueue is still starting wins', () async {
    final enqueued = h.service.enqueueFile(fatiha);
    final cancelled = h.service.cancel(fatiha);
    await enqueued;
    await cancelled;
    await h.service.whenIdle();
    await pumpEventQueue();
    expect(await h.repo.get(fatiha), isNull);
    expect(h.server.requests, isEmpty);
  });

  test('pause issued while enqueue is still starting wins', () async {
    final enqueued = h.service.enqueueFile(fatiha);
    final paused = h.service.pause(fatiha);
    await enqueued;
    await paused;
    await h.service.whenIdle();
    await pumpEventQueue();
    final item = await h.repo.get(fatiha);
    expect(item?.status, anyOf(isNull, DownloadStatus.paused));
    expect(h.server.requests, isEmpty);
  });

  test('resume during a draining pause takes effect after the drain', () async {
    await h.startHeld();
    h.server.hold = false;
    final paused = h.service.pause(fatiha);
    final resumed = h.service.resume(fatiha);
    await paused;
    await resumed;
    await h.service.whenIdle();
    expect((await h.row(fatiha)).status, DownloadStatus.done);
    expect(h.files.bytesOf(fatihaFinal), fatihaBody);
  });
}
