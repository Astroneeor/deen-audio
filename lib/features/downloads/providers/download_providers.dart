import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/providers/foundation_providers.dart';
import '../data/catalog.dart';
import '../data/catalog_loader.dart';
import '../data/download_models.dart';
import '../data/download_repository.dart';
import '../data/download_service.dart';
import '../data/library_registration.dart';
import '../../library/data/library_repository.dart';
import '../../library/providers/library_providers.dart';

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

/// Provides the [DownloadService], restored at startup (interrupted downloads
/// marked paused, nothing started). Finished Quran files are added to the
/// Library (and re-added if their track is missing) and deleted ones removed
/// from it.
final downloadServiceProvider = FutureProvider<DownloadService>((ref) async {
  final catalog = await ref.watch(catalogProvider.future);
  // Read (not watched) at call time, so a rebuilt Library repository never
  // restarts the service and aborts its transfers.
  LibraryRepository library() => ref.read(libraryRepositoryProvider);
  final service = DownloadService(
    client: ref.watch(downloadHttpClientProvider),
    files: ref.watch(fileStoreProvider),
    repo: ref.watch(downloadRepositoryProvider),
    catalog: catalog,
    onFileDone: (pack, file, path) =>
        _logged(registerDownloadedFile(library(), pack, file, path)),
    onFileRemoved: (file) =>
        _logged(unregisterDownloadedFile(library(), file)),
    registeredFiles: (ids) => library().downloadedFileIds(ids),
  );
  ref.onDispose(service.dispose);
  await service.restore();
  return service;
});

/// Brings the download service up at launch (restoring it: unfinished
/// downloads become paused, nothing starts). A failure, such as a catalog
/// that does not parse, goes to [onFailure] (logged by default) instead of
/// surfacing as an error.
void startDownloadService(
  WidgetRef ref, {
  void Function(Object error, StackTrace stack)? onFailure,
}) {
  ref.listen<AsyncValue<DownloadService>>(downloadServiceProvider, (_, next) {
    if (next case AsyncError(:final error, :final stackTrace)) {
      (onFailure ?? _logStartFailure)(error, stackTrace);
    }
  }, onError: onFailure ?? _logStartFailure);
}

void _logStartFailure(Object error, StackTrace stack) => developer.log(
  'Download service failed to start',
  name: 'downloads',
  error: error,
  stackTrace: stack,
);

/// Runs a Library write without blocking the download service; a failure is
/// logged (the file stays downloaded either way).
void _logged(Future<void> write) => unawaited(
  write.catchError((Object e, StackTrace st) {
    developer.log(
      'Library update failed',
      name: 'downloads',
      error: e,
      stackTrace: st,
    );
  }),
);

/// Provides a live list of every download row.
final downloadItemsProvider = StreamProvider<List<DownloadItem>>(
  (ref) => ref.watch(downloadRepositoryProvider).watchAll(),
);

/// Provides a live list of one pack's download rows.
final packDownloadItemsProvider =
    StreamProvider.family<List<DownloadItem>, String>(
      (ref, packId) => ref.watch(downloadRepositoryProvider).watchPack(packId),
    );

/// Provides the bytes used by downloaded files; rescanned only when a row
/// appears, disappears or changes status (not on progress writes).
final downloadsUsedBytesProvider = FutureProvider<int>((ref) async {
  ref.watch(downloadItemsProvider.select((items) => _statusKey(items.valueOrNull)));
  final service = await ref.watch(downloadServiceProvider.future);
  return service.usedBytes();
});

/// `fileId:status` of every row; equal for two lists that differ only in
/// progress.
String? _statusKey(List<DownloadItem>? items) =>
    items?.map((i) => '${i.fileId}:${i.status.name}').join(',');

/// Provides the download rows of one pack (derived from
/// [downloadItemsProvider]; empty while loading).
final packItemsProvider = Provider.family<List<DownloadItem>, String>(
  (ref, packId) => [
    for (final item in ref.watch(downloadItemsProvider).valueOrNull ?? [])
      if (item.packId == packId) item,
  ],
);

/// How far a pack has got.
typedef PackProgress = ({
  int done,
  int total,
  bool anyRunning,
  bool anyPaused,
  bool anyFailed,
});

/// Provides a pack's progress: finished files out of the catalog's files, and
/// whether any are active (queued or running), paused or failed.
final packProgressProvider = Provider.family<PackProgress, String>((
  ref,
  packId,
) {
  final pack = ref.watch(catalogProvider).valueOrNull?.pack(packId);
  final items = ref.watch(packItemsProvider(packId));
  bool any(Set<DownloadStatus> s) => items.any((i) => s.contains(i.status));
  return (
    done: items.where((i) => i.status == DownloadStatus.done).length,
    total: pack?.files.length ?? 0,
    anyRunning: any({DownloadStatus.queued, DownloadStatus.running}),
    anyPaused: any({DownloadStatus.paused}),
    anyFailed: any({DownloadStatus.failed}),
  );
});
