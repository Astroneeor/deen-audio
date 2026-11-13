// DownloadRepository against in-memory SQLite.
import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_database.dart';

DownloadItem item(
  String fileId, {
  String packId = 'p1',
  DownloadStatus status = DownloadStatus.queued,
  int bytesDone = 0,
}) => DownloadItem(
  fileId: fileId,
  packId: packId,
  status: status,
  bytesDone: bytesDone,
  bytesTotal: 100,
  relativePath: 'audio/$packId/$fileId.mp3',
);

void main() {
  late AppDatabase db;
  late DownloadRepository repo;
  final url = Uri.parse('https://example.com/a.mp3');

  setUp(() {
    db = testDatabase();
    repo = DownloadRepository(db);
  });
  tearDown(() => db.close());

  test('upsert inserts, then replaces; get reads it back', () async {
    await repo.upsert(item('f1'), url: url, checksum: 'abc');
    await repo.upsert(item('f1', bytesDone: 5), url: url);
    final got = await repo.get('f1');
    expect(got!.bytesDone, 5);
    expect(got.bytesTotal, 100);
    expect(got.status, DownloadStatus.queued);
    expect(got.relativePath, 'audio/p1/f1.mp3');
    expect((await repo.getAll()).length, 1);
    expect(await repo.get('missing'), isNull);
  });

  test('setStatus sets and clears the error; setProgress', () async {
    await repo.upsert(item('f1'), url: url);
    await repo.setStatus('f1', DownloadStatus.failed, error: 'Server 404');
    expect((await repo.get('f1'))!.error, 'Server 404');
    await repo.setStatus('f1', DownloadStatus.running);
    expect((await repo.get('f1'))!.error, isNull);
    await repo.setProgress('f1', 42, bytesTotal: 200);
    final got = (await repo.get('f1'))!;
    expect(got.bytesDone, 42);
    expect(got.bytesTotal, 200);
  });

  test('watchAll and watchPack emit current rows; delete removes', () async {
    await repo.upsert(item('a', packId: 'p1'), url: url);
    await repo.upsert(item('b', packId: 'p2'), url: url);
    expect((await repo.watchAll().first).map((i) => i.fileId), ['a', 'b']);
    expect((await repo.watchPack('p2').first).single.fileId, 'b');
    await repo.delete('a');
    expect((await repo.watchAll().first).single.fileId, 'b');
  });

  test('pauseUnfinished turns running (and queued) into paused', () async {
    await repo.upsert(item('r', status: DownloadStatus.running), url: url);
    await repo.upsert(item('q', status: DownloadStatus.queued), url: url);
    await repo.upsert(item('d', status: DownloadStatus.done), url: url);
    await repo.upsert(item('x', status: DownloadStatus.failed), url: url);
    await repo.pauseUnfinished();
    final byId = {for (final i in await repo.getAll()) i.fileId: i.status};
    expect(byId, {
      'r': DownloadStatus.paused,
      'q': DownloadStatus.paused,
      'd': DownloadStatus.done,
      'x': DownloadStatus.failed,
    });
  });
}
