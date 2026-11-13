import 'package:audio_service/audio_service.dart';
import 'package:deen_audio/core/audio/audio_player_service.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:deen_audio/features/library/data/library_scanner.dart';
import 'package:deen_audio/features/library/providers/library_providers.dart';
import 'package:deen_audio/features/library/ui/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeScanner implements LibraryScanner {
  Object? scanError;
  int picks = 0;
  final scanned = <String>[];

  @override
  Future<String?> getLastFolder() async => '/home/u/HalalAudio';

  @override
  Future<String?> pickAndScan() async {
    picks++;
    return null;
  }

  @override
  Future<void> scanPath(String dirPath) async {
    if (scanError != null) throw scanError!;
    scanned.add(dirPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Track _track(int i, TrackType type) => Track()
  ..id = i
  ..title = 'Track $i'
  ..artist = 'Artist'
  ..type = type
  ..filePath = '/m/$i.mp3';

Future<_FakeScanner> _pump(WidgetTester tester, List<Track> tracks) async {
  final scanner = _FakeScanner();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      libraryScannerProvider.overrideWithValue(scanner),
      tracksStreamProvider.overrideWith((ref) => Stream.value(tracks)),
      currentTrackProvider
          .overrideWith((ref) => Stream<MediaItem?>.value(null)),
    ],
    child: const MaterialApp(home: Scaffold(body: LibraryScreen())),
  ));
  await tester.pump();
  await tester.pump();
  return scanner;
}

void main() {
  testWidgets('Rescan re-reads the current folder without a folder picker',
      (tester) async {
    final scanner = await _pump(tester, [_track(1, TrackType.quran)]);
    expect(find.text('HalalAudio'), findsOneWidget);

    await tester.tap(find.text('Rescan'));
    await tester.pump();
    await tester.pump();

    expect(scanner.scanned, ['/home/u/HalalAudio']);
    expect(scanner.picks, 0);
  });

  testWidgets('a failed scan is shown to the user and can be retried',
      (tester) async {
    final scanner = await _pump(tester, [_track(1, TrackType.quran)]);
    scanner.scanError = const LibraryScanException('Cannot read folder');

    await tester.tap(find.text('Rescan'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Cannot read folder'), findsOneWidget);
    expect(find.text('Rescan'), findsOneWidget);
    expect(find.text('Track 1'), findsOneWidget);
  });

  testWidgets('filter chips narrow the list', (tester) async {
    await _pump(tester,
        [_track(1, TrackType.quran), _track(2, TrackType.nasheed)]);
    expect(find.text('Track 1'), findsOneWidget);
    expect(find.text('Track 2'), findsOneWidget);

    await tester.tap(find.text('Nasheeds'));
    await tester.pump();

    expect(find.text('Track 1'), findsNothing);
    expect(find.text('Track 2'), findsOneWidget);
  });

  testWidgets('a filter with no matches does not claim the library is empty',
      (tester) async {
    await _pump(tester, [_track(1, TrackType.quran)]);

    await tester.tap(find.text('White Noise'));
    await tester.pump();

    expect(find.text('Your library is empty'), findsNothing);
    expect(find.text('No White Noise tracks in your library'), findsOneWidget);
  });

  testWidgets('empty and populated states fit a small window',
      (tester) async {
    tester.view.physicalSize = const Size(560, 330);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, []);
    expect(find.text('Your library is empty'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(tester, [for (var i = 0; i < 30; i++) _track(i, TrackType.quran)]);
    expect(tester.takeException(), isNull);
  });
}
