import 'dart:io';

import 'package:deen_audio/core/models/track.dart';
import 'package:deen_audio/features/library/data/library_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/isar_test_lib.dart';

Track _track(String path, {TrackType type = TrackType.nasheed}) => Track()
  ..title = path.split('/').last
  ..type = type
  ..filePath = path;

void main() {
  late bool isarAvailable;
  late Directory tmp;
  late Isar isar;
  late LibraryRepository repo;

  setUpAll(() async => isarAvailable = await initIsarForTests());

  setUp(() async {
    if (!isarAvailable) return;
    tmp = Directory.systemTemp.createTempSync('deen_audio_repo_test');
    isar = await Isar.open([TrackSchema],
        directory: tmp.path, name: 'repo_test', inspector: false);
    repo = LibraryRepository(isar);
  });

  tearDown(() async {
    if (!isarAvailable) return;
    await isar.close(deleteFromDisk: true);
    tmp.deleteSync(recursive: true);
  });

  test('rescan keeps favourite, lastPlayed, duration and id of known files',
      () async {
    if (!isarAvailable) return markTestSkipped('Isar core binary not found');

    await repo.replaceAllTracks([_track('/m/a.mp3'), _track('/m/b.mp3')]);
    final a = (await repo.getAllTracks())
        .firstWhere((t) => t.filePath == '/m/a.mp3');
    final played = DateTime(2025, 3, 1, 8);
    a
      ..isFavorite = true
      ..lastPlayed = played
      ..duration = 123456;
    await repo.updateTrack(a);

    // The same folder is scanned again: fresh Track objects, no user state.
    await repo.replaceAllTracks([_track('/m/a.mp3'), _track('/m/b.mp3')]);

    final after = (await repo.getAllTracks())
        .firstWhere((t) => t.filePath == '/m/a.mp3');
    expect(after.isFavorite, isTrue);
    expect(after.lastPlayed, played);
    expect(after.duration, 123456);
    expect(after.id, a.id, reason: 'playlists reference tracks by id');
    expect(await repo.count(), 2);
  });

  test('rescan adds new files, removes vanished ones, refreshes metadata',
      () async {
    if (!isarAvailable) return markTestSkipped('Isar core binary not found');

    await repo.replaceAllTracks([_track('/m/a.mp3'), _track('/m/gone.mp3')]);
    await repo.replaceAllTracks([
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
    if (!isarAvailable) return markTestSkipped('Isar core binary not found');

    await repo.replaceAllTracks(
        [_track('/m/a.mp3'), _track('/m/locked/b.mp3'), _track('/m/c.mp3')]);
    final b = (await repo.getAllTracks())
        .firstWhere((t) => t.filePath == '/m/locked/b.mp3');
    await repo.toggleFavorite(b);

    await repo.replaceAllTracks([_track('/m/a.mp3')], keepUnder: ['/m/locked']);

    final all = await repo.getAllTracks();
    expect(all.map((t) => t.filePath).toSet(),
        {'/m/a.mp3', '/m/locked/b.mp3'});
    expect(all.firstWhere((t) => t.filePath == '/m/locked/b.mp3').isFavorite,
        isTrue);
  });

  test('duplicate rows for one file collapse to a single track', () async {
    if (!isarAvailable) return markTestSkipped('Isar core binary not found');

    await isar.writeTxn(
        () => isar.tracks.putAll([_track('/m/a.mp3'), _track('/m/a.mp3')]));
    await repo.replaceAllTracks([_track('/m/a.mp3')]);
    expect(await repo.count(), 1);
  });
}
