// LibraryRepository: downloaded tracks, favourites, play state, streams.
import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'support/library_repo_harness.dart';

void main() {
  final h = LibraryRepoHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  test('a downloaded track survives replaceAllTracks([])', () async {
    await h.repo.upsertDownloadedTrack(
      catalogFileId: 'f1',
      title: 'Al-Fatiha',
      artist: 'Alafasy',
      type: TrackType.quran,
      relativePath: 'packs/p1/001.mp3',
      surahNumber: '1',
    );
    await h.scan([libTrack('/m/a.mp3')]);
    await h.scan([]);

    final all = await h.repo.getAllTracks();
    expect(all.length, 1);
    expect(all.single.source, TrackSourceKind.downloaded);
    expect(all.single.trackKey, 'dl:f1');
    expect(all.single.surahNumber, '1');
    expect(all.single.artist, 'Alafasy');
  });

  test("a downloaded track's filePath is the absolute store path", () async {
    await h.repo.upsertDownloadedTrack(
      catalogFileId: 'f1',
      title: 't',
      artist: 'a',
      type: TrackType.quran,
      relativePath: 'packs/p1/001.mp3',
    );
    expect((await h.repo.getAllTracks()).single.filePath,
        await h.files.absolute('packs/p1/001.mp3'));
    expect((await h.repo.getAllTracks()).single.filePath,
        '/store/packs/p1/001.mp3');
  });

  test('upserting a downloaded track again keeps its id and favourite',
      () async {
    Future<void> upsert(String title) => h.repo.upsertDownloadedTrack(
        catalogFileId: 'f1',
        title: title,
        artist: 'a',
        type: TrackType.quran,
        relativePath: 'p/1.mp3');
    await upsert('old');
    final first = (await h.repo.getAllTracks()).single;
    await h.repo.toggleFavorite(first);
    await upsert('new');
    final second = (await h.repo.getAllTracks()).single;
    expect(second.title, 'new');
    expect(second.id, first.id);
    expect(second.isFavorite, isTrue);
  });

  test('removeDownloadedTrack removes the track', () async {
    await h.repo.upsertDownloadedTrack(
        catalogFileId: 'f1',
        title: 't',
        artist: 'a',
        type: TrackType.nasheed,
        relativePath: 'p/1.mp3');
    await h.repo.removeDownloadedTrack('f1');
    expect(await h.repo.getAllTracks(), isEmpty);
  });

  test('toggleFavorite twice stamps updatedAt each time, one state row',
      () async {
    await h.scan([libTrack('/m/a.mp3')]);
    final a = await h.byPath('/m/a.mp3');

    await h.repo.toggleFavorite(a);
    var row = (await h.db.select(h.db.trackStates).get()).single;
    expect(row.isFavorite, isTrue);
    expect(row.updatedAt, DateTime.utc(2026, 11, 13, 9));
    expect(row.deviceId, 'device-1');

    h.now = DateTime.utc(2026, 11, 13, 10);
    await h.repo.toggleFavorite(await h.byPath('/m/a.mp3'));
    row = (await h.db.select(h.db.trackStates).get()).single;
    expect(row.isFavorite, isFalse);
    expect(row.updatedAt, DateTime.utc(2026, 11, 13, 10));
    expect(row.updatedAt.isUtc, isTrue);
    expect(row.deletedAt, isNull);
  });

  test('toggleFavorite flips the stored value, not the stale Track value',
      () async {
    await h.scan([libTrack('/m/a.mp3')]);
    final stale = await h.byPath('/m/a.mp3'); // isFavorite == false
    await h.repo.toggleFavorite(await h.byPath('/m/a.mp3')); // stored: true
    stale.isFavorite = false;

    await h.repo.toggleFavorite(stale);

    final row = (await h.db.select(h.db.trackStates).get()).single;
    expect(row.isFavorite, isFalse);
    expect(stale.isFavorite, isFalse);
  });

  test('toggleFavorite and markPlayed reject an empty trackKey', () async {
    final unstored = libTrack('/m/x.mp3');
    expect(unstored.trackKey, isEmpty);
    expect(() => h.repo.toggleFavorite(unstored), throwsArgumentError);
    expect(() => h.repo.markPlayed(unstored), throwsArgumentError);
    await Future<void>.delayed(Duration.zero);
    expect(await h.db.select(h.db.trackStates).get(), isEmpty);
  });

  test('markPlayed then toggleFavorite keeps one state row with the same id',
      () async {
    await h.scan([libTrack('/m/a.mp3')]);
    final a = await h.byPath('/m/a.mp3');

    await h.repo.markPlayed(a);
    final first = (await h.db.select(h.db.trackStates).get()).single;
    await h.repo.toggleFavorite(a);

    final rows = await h.db.select(h.db.trackStates).get();
    expect(rows.length, 1);
    expect(rows.single.id, first.id);
    expect(rows.single.isFavorite, isTrue);
    expect(rows.single.lastPlayed, isNotNull);
  });

  test('watchAllTracks emits after each change', () async {
    final emissions = <List<String>>[];
    final sub = h.repo.watchAllTracks().listen((l) =>
        emissions.add([for (final t in l) '${t.title}:${t.isFavorite}']));
    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

    await settle();
    expect(emissions.last, isEmpty);

    await h.scan([libTrack('/m/a.mp3')]);
    await settle();
    expect(emissions.last, ['a.mp3:false']);

    await h.repo.toggleFavorite(await h.byPath('/m/a.mp3'));
    await settle();
    expect(emissions.last, ['a.mp3:true']);

    await h.repo.upsertDownloadedTrack(
        catalogFileId: 'f1',
        title: 'zz',
        artist: 'a',
        type: TrackType.quran,
        relativePath: 'p/1.mp3');
    await settle();
    expect(emissions.last.length, 2);
    await sub.cancel();
  });

  group('tombstoned state rows', () {
    // Favourite a track, then soft-delete its state row directly.
    Future<TrackStateRow> tombstoned() async {
      await h.scan([libTrack('/m/a.mp3')]);
      await h.repo.toggleFavorite(await h.byPath('/m/a.mp3'));
      final row = (await h.db.select(h.db.trackStates).get()).single;
      expect(row.isFavorite, isTrue);
      await (h.db.update(h.db.trackStates)
            ..where((t) => t.id.equals(row.id)))
          .write(TrackStatesCompanion(
              deletedAt: Value(DateTime.utc(2026, 11, 13, 8))));
      h.now = DateTime.utc(2026, 11, 13, 10);
      return row;
    }

    test('toggleFavorite revives with defaults, so it becomes favourite',
        () async {
      final old = await tombstoned();

      final t = await h.byPath('/m/a.mp3');
      expect(t.isFavorite, isFalse); // tombstone is invisible
      await h.repo.toggleFavorite(t);

      final rows = await h.db.select(h.db.trackStates).get();
      expect(rows.length, 1);
      expect(rows.single.id, old.id);
      expect(rows.single.deletedAt, isNull);
      expect(rows.single.updatedAt, DateTime.utc(2026, 11, 13, 10));
      expect((await h.byPath('/m/a.mp3')).isFavorite, isTrue);
    });

    test('markPlayed revives with default favourite', () async {
      final old = await tombstoned();

      await h.repo.markPlayed(await h.byPath('/m/a.mp3'));

      final rows = await h.db.select(h.db.trackStates).get();
      expect(rows.length, 1);
      expect(rows.single.id, old.id);
      expect(rows.single.deletedAt, isNull);
      final visible = await h.byPath('/m/a.mp3');
      expect(visible.isFavorite, isFalse);
      expect(visible.lastPlayed, DateTime.utc(2026, 11, 13, 10));
      expect(visible.lastPlayed!.isUtc, isTrue);
    });
  });
}
