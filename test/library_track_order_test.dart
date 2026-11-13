// Library order: Quran tracks by reciter then numeric surah, so playing the
// list as a queue goes 1, 2, 3… within one reciter.
import 'package:deen_audio/core/models/track.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/library_repo_harness.dart';

void main() {
  final h = LibraryRepoHarness();
  setUp(h.setUp);
  tearDown(h.tearDown);

  Future<void> download(String reciter, int? surah, String title) =>
      h.repo.upsertDownloadedTrack(
        catalogFileId: '$reciter-$surah-$title',
        title: title,
        artist: reciter,
        type: TrackType.quran,
        relativePath: 'audio/$reciter/$title.mp3',
        surahNumber: surah?.toString(),
      );

  test('surahs of one reciter come out in numeric order', () async {
    for (final n in [100, 2, 114, 10, 1]) {
      await download('Alafasy', n, '$n. Surah');
    }
    final titles = (await h.repo.getAllTracks()).map((t) => t.title);
    expect(titles, ['1. Surah', '2. Surah', '10. Surah', '100. Surah',
        '114. Surah']);
  });

  test('two reciters do not interleave; missing surah number sorts last',
      () async {
    await download('Sudais', 2, '2. B');
    await download('Alafasy', 2, '2. B');
    await download('Sudais', 1, '1. A');
    await download('Alafasy', null, 'Intro');
    await download('Alafasy', 1, '1. A');
    final order = (await h.repo.getAllTracks())
        .map((t) => '${t.artist}:${t.title}');
    expect(order, [
      'Alafasy:1. A',
      'Alafasy:2. B',
      'Alafasy:Intro',
      'Sudais:1. A',
      'Sudais:2. B',
    ]);
  });

  test('non-Quran tracks keep type then title order', () async {
    await h.scan([
      libTrack('/m/Nasheeds/b.mp3')..artist = 'Z',
      libTrack('/m/Nasheeds/A.mp3')..artist = 'Y',
      libTrack('/m/Noise/c.mp3', type: TrackType.whiteNoise)..artist = 'A',
      libTrack('/m/Nasheeds/10.mp3')..artist = 'X',
      libTrack('/m/Nasheeds/9.mp3')..artist = 'W',
    ]);
    await download('Alafasy', 1, '1. A');
    final order = (await h.repo.getAllTracks()).map((t) => t.title);
    expect(order, ['1. A', '10.mp3', '9.mp3', 'A.mp3', 'b.mp3', 'c.mp3']);
  });
}
