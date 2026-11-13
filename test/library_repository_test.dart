import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/core/sync/sync_stamper.dart';
import 'package:deen_audio/features/library/data/library_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_file_store.dart';
import 'support/test_database.dart';

const _root = '/m';

Track _track(String path, {TrackType type = TrackType.nasheed}) => Track()
  ..title = path.split('/').last
  ..type = type
  ..filePath = path;

void main() {
  late AppDatabase db;
  late MemoryFileStore files;
  late LibraryRepository repo;
  late DateTime now;
  var ids = 0;

  setUp(() {
    db = testDatabase();
    files = MemoryFileStore(base: '/store');
    now = DateTime.utc(2026, 11, 13, 9);
    final stamper = SyncStamper(
      session: const LocalAuthSession(deviceId: 'device-1'),
      now: () => now,
      newId: () => 'id-${ids++}',
    );
    repo = LibraryRepository(db, stamper, files);
  });
  tearDown(() => db.close());

  Future<void> scan(List<Track> tracks, {List<String> keepUnder = const []}) =>
      repo.replaceAllTracks(tracks, libraryRoot: _root, keepUnder: keepUnder);

  Future<Track> byPath(String path) async =>
      (await repo.getAllTracks()).firstWhere((t) => t.filePath == path);

  test('rescan keeps favourite, lastPlayed, duration and id of known files',
      () async {
    await scan([_track('/m/a.mp3'), _track('/m/b.mp3')]);
    final a = await byPath('/m/a.mp3');
    await repo.toggleFavorite(a);
    now = DateTime.utc(2026, 11, 14, 8);
    await repo.markPlayed(a);
    await repo.updateDuration(a, 123456);

    await scan([_track('/m/a.mp3'), _track('/m/b.mp3')]);

    final after = await byPath('/m/a.mp3');
    expect(after.isFavorite, isTrue);
    expect(after.lastPlayed, DateTime.utc(2026, 11, 14, 8));
    expect(after.lastPlayed!.isUtc, isTrue);
    expect(after.duration, 123456);
    expect(after.id, a.id, reason: 'identity survives a rescan');
    expect(after.trackKey, 'lib:a.mp3');
    expect(after.source, TrackSourceKind.scanned);
    expect((await repo.getAllTracks()).length, 2);
  });

  test('rescan adds new files, removes vanished ones, refreshes metadata',
      () async {
    await scan([_track('/m/a.mp3'), _track('/m/gone.mp3')]);
    await scan([
      _track('/m/a.mp3', type: TrackType.quran)..artist = 'Reciter',
      _track('/m/new.mp3'),
    ]);

    final all = await repo.getAllTracks();
    expect(all.map((t) => t.filePath).toSet(), {'/m/a.mp3', '/m/new.mp3'});
    final a = all.firstWhere((t) => t.filePath == '/m/a.mp3');
    expect(a.type, TrackType.quran);
    expect(a.artist, 'Reciter');
  });

  test('tracks under a folder that could not be read are not removed',
      () async {
    await scan(
        [_track('/m/a.mp3'), _track('/m/locked/b.mp3'), _track('/m/c.mp3')]);
    await repo.toggleFavorite(await byPath('/m/locked/b.mp3'));

    await scan([_track('/m/a.mp3')], keepUnder: ['/m/locked']);

    final all = await repo.getAllTracks();
    expect(all.map((t) => t.filePath).toSet(), {'/m/a.mp3', '/m/locked/b.mp3'});
    expect(all.firstWhere((t) => t.filePath == '/m/locked/b.mp3').isFavorite,
        isTrue);
  });

  test('a file missing from the new scan is removed but its state row is kept',
      () async {
    await scan([_track('/m/a.mp3'), _track('/m/b.mp3')]);
    await repo.toggleFavorite(await byPath('/m/b.mp3'));

    await scan([_track('/m/a.mp3')]);

    expect((await repo.getAllTracks()).map((t) => t.filePath), ['/m/a.mp3']);
    final states = await db.select(db.trackStates).get();
    expect(states.map((s) => s.trackKey), ['lib:b.mp3']);
    expect(states.single.isFavorite, isTrue);

    // The file comes back: the favourite is still there.
    await scan([_track('/m/a.mp3'), _track('/m/b.mp3')]);
    expect((await byPath('/m/b.mp3')).isFavorite, isTrue);
  });

  test('a downloaded track survives replaceAllTracks([])', () async {
    await repo.upsertDownloadedTrack(
      catalogFileId: 'f1',
      title: 'Al-Fatiha',
      artist: 'Alafasy',
      type: TrackType.quran,
      relativePath: 'packs/p1/001.mp3',
      surahNumber: '1',
    );
    await scan([_track('/m/a.mp3')]);
    await scan([]);

    final all = await repo.getAllTracks();
    expect(all.length, 1);
    expect(all.single.source, TrackSourceKind.downloaded);
    expect(all.single.trackKey, 'dl:f1');
    expect(all.single.surahNumber, '1');
    expect(all.single.artist, 'Alafasy');
  });

  test("a downloaded track's filePath is the absolute store path", () async {
    await repo.upsertDownloadedTrack(
      catalogFileId: 'f1',
      title: 't',
      artist: 'a',
      type: TrackType.quran,
      relativePath: 'packs/p1/001.mp3',
    );
    expect((await repo.getAllTracks()).single.filePath,
        await files.absolute('packs/p1/001.mp3'));
    expect((await repo.getAllTracks()).single.filePath,
        '/store/packs/p1/001.mp3');
  });

  test('upserting a downloaded track again keeps its id and favourite',
      () async {
    Future<void> upsert(String title) => repo.upsertDownloadedTrack(
        catalogFileId: 'f1',
        title: title,
        artist: 'a',
        type: TrackType.quran,
        relativePath: 'p/1.mp3');
    await upsert('old');
    final first = (await repo.getAllTracks()).single;
    await repo.toggleFavorite(first);
    await upsert('new');
    final second = (await repo.getAllTracks()).single;
    expect(second.title, 'new');
    expect(second.id, first.id);
    expect(second.isFavorite, isTrue);
  });

  test('removeDownloadedTrack removes the track', () async {
    await repo.upsertDownloadedTrack(
        catalogFileId: 'f1',
        title: 't',
        artist: 'a',
        type: TrackType.nasheed,
        relativePath: 'p/1.mp3');
    await repo.removeDownloadedTrack('f1');
    expect(await repo.getAllTracks(), isEmpty);
  });

  test('toggleFavorite twice stamps updatedAt each time, one state row',
      () async {
    await scan([_track('/m/a.mp3')]);
    final a = await byPath('/m/a.mp3');

    await repo.toggleFavorite(a);
    var row = (await db.select(db.trackStates).get()).single;
    expect(row.isFavorite, isTrue);
    expect(row.updatedAt, DateTime.utc(2026, 11, 13, 9));
    expect(row.deviceId, 'device-1');

    now = DateTime.utc(2026, 11, 13, 10);
    await repo.toggleFavorite(await byPath('/m/a.mp3'));
    row = (await db.select(db.trackStates).get()).single;
    expect(row.isFavorite, isFalse);
    expect(row.updatedAt, DateTime.utc(2026, 11, 13, 10));
    expect(row.updatedAt.isUtc, isTrue);
    expect(row.deletedAt, isNull);
  });

  test('watchAllTracks emits after each change', () async {
    final emissions = <List<String>>[];
    final sub = repo.watchAllTracks().listen((l) =>
        emissions.add([for (final t in l) '${t.title}:${t.isFavorite}']));
    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

    await settle();
    expect(emissions.last, isEmpty);

    await scan([_track('/m/a.mp3')]);
    await settle();
    expect(emissions.last, ['a.mp3:false']);

    await repo.toggleFavorite(await byPath('/m/a.mp3'));
    await settle();
    expect(emissions.last, ['a.mp3:true']);

    await repo.upsertDownloadedTrack(
        catalogFileId: 'f1',
        title: 'zz',
        artist: 'a',
        type: TrackType.quran,
        relativePath: 'p/1.mp3');
    await settle();
    expect(emissions.last.length, 2);
    await sub.cancel();
  });
}
