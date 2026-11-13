// Downloads screen: the per-file list and the pack menu.
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downloads_screen_harness.dart';

void main() {
  testWidgets('Choose surahs lists files with per-file state and actions', (
    tester,
  ) async {
    final actions = await pumpDownloadsScreen(
      tester,
      items: [
        downloadItem('test-reciter-001', DownloadStatus.done),
        downloadItem(
          'test-reciter-113',
          DownloadStatus.failed,
          error: 'Checksum mismatch',
        ),
      ],
    );
    await tester.tap(find.text('Choose surahs'));
    await tester.pumpAndSettle();

    expect(find.text('2. Al-Baqara'), findsOneWidget);
    expect(find.text('Checksum mismatch'), findsOneWidget);
    expect(find.text('Test data only.'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry 113. Al-Falaq'));
    await tester.tap(find.byTooltip('Download 2. Al-Baqara'));
    await tester.pump();
    expect(actions.calls, [
      'resumeFile test-reciter-113',
      'downloadFile test-reciter-002',
    ]);
  });

  testWidgets('deleting one file asks first', (tester) async {
    final actions = await pumpDownloadsScreen(
      tester,
      items: [downloadItem('test-reciter-001', DownloadStatus.done)],
    );
    await tester.tap(find.text('Choose surahs'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete 1. Al-Faatiha'));
    await tester.pumpAndSettle();
    expect(actions.calls, isEmpty);
    expect(find.text('Delete download?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(actions.calls, isEmpty);

    await tester.tap(find.byTooltip('Delete 1. Al-Faatiha'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['deleteFile test-reciter-001']);
    // The file list stays open.
    expect(find.text('2. Al-Baqara'), findsOneWidget);
  });

  testWidgets('the menu shows the licence and copies the source link', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await pumpDownloadsScreen(tester);

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Licence and source'));
    await tester.pumpAndSettle();
    expect(find.text('Test data only.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy source page link'));
    await tester.pumpAndSettle();
    expect(copied, 'https://example.com/reciter');
    expect(find.textContaining('Link copied'), findsOneWidget);
  });

  testWidgets('deleting a pack asks first', (tester) async {
    final actions = await pumpDownloadsScreen(
      tester,
      items: [downloadItem('test-reciter-001', DownloadStatus.done)],
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete downloads'));
    await tester.pumpAndSettle();
    expect(actions.calls, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['deletePack test-reciter']);
  });
}
