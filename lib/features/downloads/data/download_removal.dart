import '../../../core/storage/file_store.dart';
import 'catalog.dart';
import 'download_callbacks.dart';
import 'download_models.dart';
import 'download_repository.dart';

/// Deletes downloads (files, `.part`s, rows) for the download service and
/// remembers the deletes in progress, so an enqueue of the same file can
/// wait for them.
class DownloadRemover {
  DownloadRemover({
    required this.catalog,
    required this.files,
    required this.repo,
    required this.pathFor,
    this.onRemoved,
  });

  final Catalog catalog;
  final FileStore files;
  final DownloadRepository repo;
  final String Function(CatalogPack, CatalogFile) pathFor;

  /// Called for each removed file that had been downloaded (on disk or
  /// marked done), so its Library track can go too.
  final void Function(CatalogFile)? onRemoved;

  final Map<String, Future<void>> _pending = {};

  /// The delete of [fileId] in progress, if any.
  Future<void>? pending(String fileId) => _pending[fileId];

  /// Runs [stop] (which stops the transfers of [ids]), then deletes [ids]
  /// and [dir]. Registered as pending synchronously, so a re-enqueue issued
  /// meanwhile runs after the delete, not under it.
  Future<void> remove(
    Set<String> ids, {
    required Future<void> Function() stop,
    String? dir,
  }) {
    final done = () async {
      await stop();
      await _removeNow(ids, dir);
    }();
    for (final id in ids) {
      _pending[id] = done;
    }
    return done.whenComplete(() {
      for (final id in ids) {
        if (identical(_pending[id], done)) _pending.remove(id);
      }
    });
  }

  Future<void> _removeNow(Set<String> ids, String? dir) async {
    for (final id in ids) {
      final (pack, file) = catalog.requireFile(id);
      final path = pathFor(pack, file);
      final hadFile = await files.exists(path);
      final item = await repo.get(id);
      await files.delete('$path.part');
      await files.delete(path);
      await repo.delete(id);
      if (hadFile || item?.status == DownloadStatus.done) {
        runLogged(() => onRemoved?.call(file));
      }
    }
    if (dir != null) await files.deleteDir(dir);
  }
}
