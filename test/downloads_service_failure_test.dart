// DownloadService failures: HTTP errors, offline, disk errors, stale catalog
// sizes, bad resumes, stalled connections and database errors.
import 'dart:io';

import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'support/download_harness.dart';

/// A repository whose [setProgress] throws from its second call on (the
/// first write inside the streaming loop), and whose first `failed` status
/// write throws too.
class _BrokenRepo extends DownloadRepository {
  _BrokenRepo(super.db);
  var progressCalls = 0;
  var failWritesToThrow = 1;

  @override
  Future<void> setProgress(String fileId, int bytesDone, {int? bytesTotal}) {
    if (++progressCalls >= 2) {
      return Future.error(StateError('database is locked'));
    }
    return super.setProgress(fileId, bytesDone, bytesTotal: bytesTotal);
  }

  @override
  Future<void> setStatus(
    String fileId,
    DownloadStatus status, {
    String? error,
  }) {
    if (status == DownloadStatus.failed && failWritesToThrow-- > 0) {
      return Future.error(StateError('database is locked'));
    }
    return super.setStatus(fileId, status, error: error);
  }
}

void main() {
  final h = DownloadHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  test('404: failed with a reason containing 404', () async {
    h.server.statusFor['/audio/113.mp3'] = 404;
    await h.service.enqueueFile('test-reciter-113');
    await h.service.whenIdle();
    final item = await h.row('test-reciter-113');
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('404'));
    expect(await h.files.exists('audio/test-reciter/113.mp3'), isFalse);
  });

  test('offline: failed with a readable reason', () async {
    h.server.connectError = http.ClientException('Failed host lookup');
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();
    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('Could not reach'));
  });

  test(
    'a write error from the store: failed, readable, no final file',
    () async {
      h.files.writeError = const FileSystemException('No space left on device');
      await h.service.enqueueFile(fatiha);
      await h.service.whenIdle();
      final item = await h.row(fatiha);
      expect(item.status, DownloadStatus.failed);
      expect(item.error, contains('Could not save'));
      expect(item.error, contains('No space left on device'));
      // The chunk is not counted: the failed flush means it was not written.
      expect(item.bytesDone, 0);
      expect(await h.files.exists(fatihaFinal), isFalse);
      expect(h.done, isEmpty);
    },
  );

  test('server size differs from the catalog: fails before streaming, '
      'no .part, nothing written', () async {
    h.server.bodies[fatihaUrl] = [1, 2, 3, 4, 5, 6];
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('The catalog is out of date for this file'));
    expect(item.bytesDone, 0);
    expect(await h.files.exists(fatihaPart), isFalse);
    expect(await h.files.exists(fatihaFinal), isFalse);
  });

  test('a 206 whose Content-Range total differs from the catalog fails '
      'before streaming', () async {
    h.files.files[fatihaPart] = [1, 2, 3, 4];
    h.server.bodies[fatihaUrl] = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await h.row(fatiha);
    expect(item.error, contains('The catalog is out of date for this file'));
    expect(await h.files.exists(fatihaPart), isFalse);
  });

  test('a 206 without Content-Range: .part deleted, failed', () async {
    h.files.files[fatihaPart] = [1, 2, 3, 4];
    h.server.omitContentRange = true;
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle();

    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.failed);
    expect(item.error, contains('wrong position'));
    expect(await h.files.exists(fatihaPart), isFalse);
    expect(await h.files.exists(fatihaFinal), isFalse);
  });

  test(
    'a body that stops mid-stream fails as stalled and keeps the .part',
    () async {
      await h.replaceService(
        () => h.newService(stallTimeout: const Duration(milliseconds: 50)),
      );
      await h.startHeld();
      await h.service.whenIdle().timeout(const Duration(seconds: 5));

      final item = await h.row(fatiha);
      expect(item.status, DownloadStatus.failed);
      expect(item.error, 'Connection stalled. Resume to continue.');
      expect(h.files.bytesOf(fatihaPart), [1, 2, 3]);
      expect(await h.files.exists(fatihaFinal), isFalse);
    },
  );

  test('database errors: generic reason, row not left running, no uncaught '
      'error', () async {
    final broken = _BrokenRepo(h.db);
    await h.replaceService(
      () => h.newService(repository: broken, progressInterval: Duration.zero),
    );
    await h.service.enqueueFile(fatiha);
    await h.service.whenIdle().timeout(const Duration(seconds: 5));

    final item = await h.row(fatiha);
    expect(item.status, DownloadStatus.failed);
    expect(item.error, startsWith('Download failed: '));
    expect(item.error, contains('database is locked'));
    expect(item.error, isNot(contains('Connection lost')));
    expect(await h.files.exists(fatihaFinal), isFalse);
  });
}
