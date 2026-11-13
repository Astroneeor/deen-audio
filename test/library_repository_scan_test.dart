// LibraryRepository: rescans and track keys.
import 'package:deen_audio/core/models/track.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/library_repo_harness.dart';

void main() {
  final h = LibraryRepoHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  test('rescan keeps favourite, lastPlayed, duration and id of known files',
      () async {
    await h.scan([libTrack('/m/a.mp3'), libTrack('/m/b.mp3')]);
    final a = await h.byPath('/m/a.mp3');
    await h.repo.toggleFavorite(a);
    h.now = DateTime.utc(2026, 11, 14, 8);
    await h.repo.markPlayed(a);
    await h.repo.updateDuration(a, 123456);

    await h.scan([libTrack('/m/a.mp3'), libTrack('/m/b.mp3')]);

    final after = await h.byPath('/m/a.mp3');
    expect(after.isFavorite, isTrue);
    expect(after.lastPlayed, DateTime.utc(2026, 11, 14, 8));
    expect(after.lastPlayed!.isUtc, isTrue);
    expect(after.duration, 123456);
    expect(after.id, a.id, reason: 'identity survives a rescan');
    expect(after.trackKey, 'lib:a.mp3');
    expect(after.source, TrackSourceKind.scanned);
    expect((await h.repo.getAllTracks()).length, 2);
  });

  test('rescan adds new files, removes vanished ones, refreshes metadata',
      () async {
    await h.scan([libTrack('/m/a.mp3'), libTrack('/m/gone.mp3')]);
    await h.scan([
      libTrack('/m/a.mp3', type: TrackType.quran)..artist = 'Reciter',
      libTrack('/m/new.mp3'),
    ]);

    final all = await h.repo.getAllTracks();
    expect(all.map((t) => t.filePath).toSet(), {'/m/a.mp3', '/m/new.mp3'});
    final a = all.firstWhere((t) => t.filePath == '/m/a.mp3');
    expect(a.type, TrackType.quran);
    expect(a.artist, 'Reciter');
  });

  test('tracks under a folder that could not be read are not removed',
      () async {
    await h.scan(
        [libTrack('/m/a.mp3'), libTrack('/m/locked/b.mp3'), libTrack('/m/c.mp3')]);
    await h.repo.toggleFavorite(await h.byPath('/m/locked/b.mp3'));

    await h.scan([libTrack('/m/a.mp3')], keepUnder: ['/m/locked']);

    final all = await h.repo.getAllTracks();
    expect(all.map((t) => t.filePath).toSet(), {'/m/a.mp3', '/m/locked/b.mp3'});
    expect(all.firstWhere((t) => t.filePath == '/m/locked/b.mp3').isFavorite,
        isTrue);
  });

  test('a file missing from the new scan is removed but its state row is kept',
      () async {
    await h.scan([libTrack('/m/a.mp3'), libTrack('/m/b.mp3')]);
    await h.repo.toggleFavorite(await h.byPath('/m/b.mp3'));

    await h.scan([libTrack('/m/a.mp3')]);

    expect((await h.repo.getAllTracks()).map((t) => t.filePath), ['/m/a.mp3']);
    final states = await h.db.select(h.db.trackStates).get();
    expect(states.map((s) => s.trackKey), ['lib:b.mp3']);
    expect(states.single.isFavorite, isTrue);

    // The file comes back: the favourite is still there.
    await h.scan([libTrack('/m/a.mp3'), libTrack('/m/b.mp3')]);
    expect((await h.byPath('/m/b.mp3')).isFavorite, isTrue);
  });

  test('nested file gets a posix key and its favourite survives a rescan',
      () async {
    const path = '/m/Quran/Alafasy/001.mp3';
    await h.scan([libTrack(path, type: TrackType.quran)]);
    final t = await h.byPath(path);
    expect(t.trackKey, 'lib:Quran/Alafasy/001.mp3');
    await h.repo.toggleFavorite(t);

    await h.scan([libTrack(path, type: TrackType.quran)]);

    final after = await h.byPath(path);
    expect(after.trackKey, 'lib:Quran/Alafasy/001.mp3');
    expect(after.isFavorite, isTrue);
  });

  test('a library root with a trailing slash gives the same keys', () async {
    final paths = ['/m/a.mp3', '/m/Quran/Alafasy/001.mp3'];
    await h.repo.replaceAllTracks([for (final x in paths) libTrack(x)],
        libraryRoot: '/m');
    final plain = {for (final t in await h.repo.getAllTracks()) t.trackKey};

    await h.repo.replaceAllTracks([for (final x in paths) libTrack(x)],
        libraryRoot: '/m/');
    final slashed = {for (final t in await h.repo.getAllTracks()) t.trackKey};

    expect(slashed, plain);
    expect(slashed, {'lib:a.mp3', 'lib:Quran/Alafasy/001.mp3'});
  });
}
