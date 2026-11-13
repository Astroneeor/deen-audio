// Downloads screen: pack cards, per-state actions, the shelves, widths.
import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downloads_screen_harness.dart';

void main() {
  testWidgets('Reciters tab lists catalog packs with their source', (
    tester,
  ) async {
    await pumpDownloadsScreen(tester);
    expect(find.text('Reciters'), findsOneWidget);
    expect(find.text('Adhkar'), findsOneWidget);
    expect(find.text('Test Reciter'), findsOneWidget);
    expect(find.textContaining('Example Source'), findsOneWidget);
    expect(find.text('Test Adhkar Scans'), findsNothing);
  });

  testWidgets('a pack with nothing downloaded offers Download all', (
    tester,
  ) async {
    final actions = await pumpDownloadsScreen(tester);
    expect(find.text('Not downloaded'), findsOneWidget);
    expect(find.text('Choose surahs'), findsOneWidget);

    await tester.tap(find.text('Download all'));
    await tester.pump();
    expect(actions.calls, ['downloadPack test-reciter']);
  });

  testWidgets('a partly downloaded running pack shows progress and Pause', (
    tester,
  ) async {
    final actions = await pumpDownloadsScreen(
      tester,
      items: [
        downloadItem('test-reciter-001', DownloadStatus.done),
        downloadItem('test-reciter-112', DownloadStatus.running),
      ],
    );
    expect(find.text('1 of 5 surahs'), findsOneWidget);
    expect(find.text('Download all'), findsNothing);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(actions.calls, ['pausePack test-reciter']);
  });

  testWidgets('a paused pack offers Resume', (tester) async {
    final actions = await pumpDownloadsScreen(
      tester,
      items: [downloadItem('test-reciter-112', DownloadStatus.paused)],
    );
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(actions.calls, ['resumePack test-reciter']);
  });

  testWidgets('a failed file shows its reason and a Retry', (tester) async {
    final actions = await pumpDownloadsScreen(
      tester,
      items: [
        downloadItem('test-reciter-001', DownloadStatus.done),
        downloadItem(
          'test-reciter-113',
          DownloadStatus.failed,
          error: 'The server answered 404',
        ),
      ],
    );
    expect(find.textContaining('The server answered 404'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(actions.calls, ['resumePack test-reciter']);
  });

  testWidgets('the Adhkar tab lists scan packs', (tester) async {
    await pumpDownloadsScreen(tester);
    await tester.tap(find.text('Adhkar'));
    await tester.pumpAndSettle();
    expect(find.text('Test Adhkar Scans'), findsOneWidget);
    expect(find.text('Choose files'), findsOneWidget);
  });

  testWidgets('the Adhkar tab with no packs says Nothing here yet', (
    tester,
  ) async {
    final reciterOnly = Catalog([fixtureCatalog.pack('test-reciter')!]);
    await pumpDownloadsScreen(tester, catalog: reciterOnly);
    await tester.tap(find.text('Adhkar'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('the header shows the disk space used', (tester) async {
    await pumpDownloadsScreen(tester, usedBytes: 1288490189);
    expect(find.text('1.2 GB used'), findsOneWidget);
  });

  testWidgets('a 700 px window does not overflow', (tester) async {
    tester.view.physicalSize = const Size(700, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpDownloadsScreen(
      tester,
      usedBytes: 123456789,
      items: [
        downloadItem('test-reciter-001', DownloadStatus.done),
        downloadItem(
          'test-reciter-113',
          DownloadStatus.failed,
          error: 'A rather long reason that should wrap or be cut cleanly',
        ),
      ],
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Choose surahs'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
