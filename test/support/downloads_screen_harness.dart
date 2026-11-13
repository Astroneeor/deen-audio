// Shared setup for the Downloads screen widget tests: fixture catalog,
// download rows and recorded actions, no database.
import 'dart:io';

import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/providers/download_actions.dart';
import 'package:deen_audio/features/downloads/providers/download_providers.dart';
import 'package:deen_audio/features/downloads/ui/downloads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the screen asked for instead of downloading anything.
class FakeDownloadActions implements DownloadActions {
  final calls = <String>[];

  @override
  Future<void> downloadPack(String id) async => calls.add('downloadPack $id');
  @override
  Future<void> downloadFile(String id) async => calls.add('downloadFile $id');
  @override
  Future<void> pausePack(String id) async => calls.add('pausePack $id');
  @override
  Future<void> pauseFile(String id) async => calls.add('pauseFile $id');
  @override
  Future<void> resumePack(String id) async => calls.add('resumePack $id');
  @override
  Future<void> resumeFile(String id) async => calls.add('resumeFile $id');
  @override
  Future<void> deletePack(String id) async => calls.add('deletePack $id');
  @override
  Future<void> deleteFile(String id) async => calls.add('deleteFile $id');
}

final fixtureCatalog = Catalog.parse(
  File('test/fixtures/catalog_fixture.json').readAsStringSync(),
);

DownloadItem downloadItem(
  String fileId,
  DownloadStatus status, {
  String packId = 'test-reciter',
  String? error,
  int bytesDone = 0,
  int? bytesTotal,
}) => DownloadItem(
  fileId: fileId,
  packId: packId,
  status: status,
  relativePath: 'audio/$packId/$fileId.mp3',
  error: error,
  bytesDone: bytesDone,
  bytesTotal: bytesTotal,
);

Future<FakeDownloadActions> pumpDownloadsScreen(
  WidgetTester tester, {
  List<DownloadItem> items = const [],
  Catalog? catalog,
  int usedBytes = 0,
}) async {
  final actions = FakeDownloadActions();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogProvider.overrideWith((ref) async => catalog ?? fixtureCatalog),
        downloadItemsProvider.overrideWith((ref) => Stream.value(items)),
        downloadsUsedBytesProvider.overrideWith((ref) async => usedBytes),
        downloadActionsProvider.overrideWithValue(actions),
      ],
      // A 220 px strip stands in for the app sidebar.
      child: const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(width: 220),
              Expanded(child: DownloadsScreen()),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return actions;
}
