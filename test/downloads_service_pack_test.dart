// "Download all" races: a pack pause/delete pressed while enqueuePack is
// still walking the pack's files stops the walk.
import 'dart:async';

import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/download_harness.dart';

/// Holds `get` of [ikhlaas] (the pack's second file) until [gate] completes,
/// so the pack walk is stopped part-way.
class _GatedRepo extends DownloadRepository {
  _GatedRepo(super.db);
  final gate = Completer<void>();
  final reached = Completer<void>();

  @override
  Future<DownloadItem?> get(String fileId) async {
    if (fileId == ikhlaas && !gate.isCompleted) {
      if (!reached.isCompleted) reached.complete();
      await gate.future;
    }
    return super.get(fileId);
  }
}

void main() {
  final h = DownloadHarness();
  late _GatedRepo gated;
  setUp(() async {
    h.setUp();
    gated = _GatedRepo(h.db);
    await h.replaceService(() => h.newService(repository: gated));
  });
  tearDown(h.tearDown);

  /// Waits until the walk is at the second file (the first is queued).
  Future<void> untilFirstRow() async {
    await gated.reached.future.timeout(const Duration(seconds: 5));
    expect(await h.repo.get(fatiha), isNotNull);
  }

  /// Lets the walk continue.
  void release() => gated.gate.complete();

  test('deletePack during Download all: no file comes back', () async {
    h.server.hold = true;
    final all = h.service.enqueuePack('test-reciter');
    await untilFirstRow();

    final delete = h.service.deletePack('test-reciter');
    release();
    await delete;
    await all;
    await h.service.whenIdle();

    expect(await h.repo.getAll(), isEmpty);
    expect(await h.files.usedBytes('audio'), 0);
  });

  test('pausePack during Download all: nothing is left queued or running',
      () async {
    h.server.hold = true;
    final all = h.service.enqueuePack('test-reciter');
    await untilFirstRow();

    final pause = h.service.pausePack('test-reciter');
    release();
    await pause;
    await all;
    await pumpEventQueue();

    final statuses = (await h.repo.getAll()).map((i) => i.status).toSet();
    expect(statuses.difference({DownloadStatus.paused}), isEmpty);
    expect(h.service.whenIdle(), completes);
  });

  test('Download all after a pause walks the whole pack again', () async {
    h.server.hold = true;
    final first = h.service.enqueuePack('test-reciter');
    await untilFirstRow();
    final pause = h.service.pausePack('test-reciter');
    release();
    await pause;
    await first;

    h.server.hold = false;
    await h.service.enqueuePack('test-reciter');
    expect((await h.repo.getAll()).length, 5);
  });
}
