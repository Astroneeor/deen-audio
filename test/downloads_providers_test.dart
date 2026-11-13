// Download providers: the service comes up restored and starts nothing.
import 'dart:io';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/providers/foundation_providers.dart';
import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/catalog_loader.dart';
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_repository.dart';
import 'package:deen_audio/features/downloads/providers/download_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_download_server.dart';
import 'support/memory_file_store.dart';
import 'support/test_database.dart';

/// Counts [usedBytes] calls (each one is a directory scan on disk).
class _CountingStore extends MemoryFileStore {
  int usedBytesCalls = 0;

  @override
  Future<int> usedBytes(String relDir) {
    usedBytesCalls++;
    return super.usedBytes(relDir);
  }
}

class _FixtureLoader implements CatalogLoader {
  @override
  Future<Catalog> load() async => Catalog.parse(
    File('test/fixtures/catalog_fixture.json').readAsStringSync(),
  );
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('downloadServiceProvider restores without any request', () async {
    final server = FakeDownloadServer({});
    await DownloadRepository(db).upsert(
      const DownloadItem(
        fileId: 'test-reciter-001',
        packId: 'test-reciter',
        status: DownloadStatus.running,
        relativePath: 'audio/test-reciter/001.mp3',
      ),
      url: Uri.parse('https://example.com/audio/001.mp3'),
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        downloadHttpClientProvider.overrideWithValue(server.client),
        catalogLoaderProvider.overrideWithValue(_FixtureLoader()),
      ],
    );
    addTearDown(container.dispose);

    final service = await container.read(downloadServiceProvider.future);
    expect(service.catalog.packs.length, 2);
    final items = await container.read(downloadItemsProvider.future);
    expect(items.single.status, DownloadStatus.paused);
    expect(await container.read(downloadsUsedBytesProvider.future), 0);
    expect(server.requests, isEmpty);
  });

  test('progress writes do not rescan used bytes; status changes do', () async {
    final store = _CountingStore();
    final repo = DownloadRepository(db);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(store),
        downloadHttpClientProvider.overrideWithValue(
          FakeDownloadServer({}).client,
        ),
        catalogLoaderProvider.overrideWithValue(_FixtureLoader()),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(downloadsUsedBytesProvider, (_, _) {});
    addTearDown(sub.close);

    await repo.upsert(
      const DownloadItem(
        fileId: 'test-reciter-001',
        packId: 'test-reciter',
        status: DownloadStatus.running,
        relativePath: 'audio/test-reciter/001.mp3',
      ),
      url: Uri.parse('https://example.com/audio/001.mp3'),
    );
    await container.read(downloadsUsedBytesProvider.future);
    await pumpEventQueue();
    final before = store.usedBytesCalls;

    for (var i = 1; i <= 10; i++) {
      await repo.setProgress('test-reciter-001', i);
      await pumpEventQueue();
      await container.read(downloadsUsedBytesProvider.future);
    }
    expect(store.usedBytesCalls - before, lessThanOrEqualTo(1));

    await repo.setStatus('test-reciter-001', DownloadStatus.done);
    await pumpEventQueue();
    await container.read(downloadsUsedBytesProvider.future);
    expect(store.usedBytesCalls, greaterThan(before));
  });
}
