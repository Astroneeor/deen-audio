import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/providers/foundation_providers.dart';
import '../data/catalog.dart';
import '../data/catalog_loader.dart';
import '../data/download_models.dart';
import '../data/download_repository.dart';
import '../data/download_service.dart';

/// Provides where the download catalog is loaded from (the bundled asset).
final catalogLoaderProvider = Provider<CatalogLoader>(
  (ref) => const AssetCatalogLoader(),
);

/// Provides the parsed download catalog.
final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.watch(catalogLoaderProvider).load(),
);

/// Provides the HTTP client used for downloads; closed with the container.
final downloadHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Provides the [DownloadRepository] over `download_items`.
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => DownloadRepository(ref.watch(appDatabaseProvider)),
);

/// Provides the [DownloadService], restored (interrupted downloads marked
/// paused, nothing started). Library registration via `onFileDone` /
/// `onFileRemoved` is wired by the Downloads/Library integration.
final downloadServiceProvider = FutureProvider<DownloadService>((ref) async {
  final service = DownloadService(
    client: ref.watch(downloadHttpClientProvider),
    files: ref.watch(fileStoreProvider),
    repo: ref.watch(downloadRepositoryProvider),
    catalog: await ref.watch(catalogProvider.future),
  );
  ref.onDispose(service.dispose);
  await service.restore();
  return service;
});

/// Provides a live list of every download row.
final downloadItemsProvider = StreamProvider<List<DownloadItem>>(
  (ref) => ref.watch(downloadRepositoryProvider).watchAll(),
);

/// Provides a live list of one pack's download rows.
final packDownloadItemsProvider =
    StreamProvider.family<List<DownloadItem>, String>(
      (ref, packId) => ref.watch(downloadRepositoryProvider).watchPack(packId),
    );

/// Provides the bytes used by downloaded files; refreshed whenever the
/// download rows change.
final downloadsUsedBytesProvider = FutureProvider<int>((ref) async {
  ref.watch(downloadItemsProvider);
  final service = await ref.watch(downloadServiceProvider.future);
  return service.usedBytes();
});
