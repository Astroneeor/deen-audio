// Downloads → Library wiring through the real providers, database and
// repositories (fake HTTP, in-memory file store).
import 'dart:convert';
import 'dart:io';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:deen_audio/core/providers/foundation_providers.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/catalog_loader.dart';
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_service.dart';
import 'package:deen_audio/features/downloads/providers/download_providers.dart';
import 'package:deen_audio/features/library/data/library_repository.dart';
import 'package:deen_audio/features/library/providers/library_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_download_server.dart';
import 'support/memory_file_store.dart';
import 'support/test_database.dart';

class _FixtureLoader implements CatalogLoader {
  @override
  Future<Catalog> load() async => Catalog.parse(
    File('test/fixtures/catalog_fixture.json').readAsStringSync(),
  );
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late DownloadService service;
  late LibraryRepository library;

  setUp(() async {
    db = testDatabase();
    final server = FakeDownloadServer({
      '/audio/001.mp3': [1, 2, 3, 4, 5, 6, 7, 8],
      '/audio/112.mp3': utf8.encode('ikhlaas!'),
      '/scans/morning-1.jpg': [0xff, 0xd8, 0xff],
    });
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authSessionProvider.overrideWithValue(
          const LocalAuthSession(deviceId: 'device-1'),
        ),
        fileStoreProvider.overrideWithValue(MemoryFileStore(base: '/store')),
        downloadHttpClientProvider.overrideWithValue(server.client),
        catalogLoaderProvider.overrideWithValue(_FixtureLoader()),
      ],
    );
    service = await container.read(downloadServiceProvider.future);
    library = container.read(libraryRepositoryProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<List<Track>> tracksWhere(bool Function(List<Track>) test) => library
      .watchAllTracks()
      .firstWhere(test)
      .timeout(const Duration(seconds: 5));

  test('a completed reciter file becomes a downloaded Quran track', () async {
    await service.enqueueFile('test-reciter-001');
    await service.whenIdle();

    final tracks = await tracksWhere((t) => t.isNotEmpty);
    final track = tracks.single;
    expect(track.source, TrackSourceKind.downloaded);
    expect(track.type, TrackType.quran);
    expect(track.artist, 'Test Reciter');
    expect(track.surahNumber, '1');
    expect(track.trackKey, 'dl:test-reciter-001');
    expect(track.filePath, '/store/audio/test-reciter/001.mp3');
  });

  test('a done file whose track is missing is re-registered on enqueue',
      () async {
    await service.enqueueFile('test-reciter-001');
    await service.whenIdle();
    await tracksWhere((t) => t.isNotEmpty);
    // As if adding the track had failed when the download finished.
    await library.removeDownloadedTrack('test-reciter-001');
    await tracksWhere((t) => t.isEmpty);

    await service.enqueueFile('test-reciter-001');
    final tracks = await tracksWhere((t) => t.isNotEmpty);
    expect(tracks.single.trackKey, 'dl:test-reciter-001');
  });

  test('restore() re-adds tracks missing for done reciter files', () async {
    await service.enqueueFile('test-reciter-001');
    await service.enqueueFile('test-scans-morning');
    await service.whenIdle();
    await tracksWhere((t) => t.isNotEmpty);
    await library.removeDownloadedTrack('test-reciter-001');
    await tracksWhere((t) => t.isEmpty);

    await service.restore();
    final tracks = await tracksWhere((t) => t.isNotEmpty);
    expect(tracks.map((t) => t.trackKey), ['dl:test-reciter-001']);
  });

  test('deleting the pack removes its tracks', () async {
    await service.enqueuePack('test-reciter');
    await service.whenIdle();
    await tracksWhere((t) => t.length == 2);

    await service.deletePack('test-reciter');
    expect(await tracksWhere((t) => t.isEmpty), isEmpty);
  });

  test('deleting one file removes only its track', () async {
    await service.enqueueFile('test-reciter-001');
    await service.enqueueFile('test-reciter-112');
    await service.whenIdle();
    await tracksWhere((t) => t.length == 2);

    await service.deleteFile('test-reciter-001');
    final left = await tracksWhere((t) => t.length == 1);
    expect(left.single.trackKey, 'dl:test-reciter-112');
  });

  test('an adhkarScans file completes without adding a track', () async {
    await service.enqueueFile('test-scans-morning');
    await service.whenIdle();
    await pumpEventQueue();

    final item = await container
        .read(downloadRepositoryProvider)
        .get('test-scans-morning');
    expect(item!.status, DownloadStatus.done);
    expect(await library.getAllTracks(), isEmpty);
  });

  test('packProgressProvider counts finished files of the pack', () async {
    final sub = container.listen(downloadItemsProvider, (_, _) {});
    addTearDown(sub.close);
    await service.enqueueFile('test-reciter-001');
    await service.whenIdle();
    await container
        .read(downloadItemsProvider.future)
        .then((_) => pumpEventQueue());
    await tracksWhere((t) => t.isNotEmpty);

    final progress = container.read(packProgressProvider('test-reciter'));
    expect(progress.done, 1);
    expect(progress.total, 5);
    expect(progress.anyRunning, isFalse);
    expect(progress.anyFailed, isFalse);
  });
}
