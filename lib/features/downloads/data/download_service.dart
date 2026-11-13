import 'dart:async';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../core/storage/file_store.dart';
import 'catalog.dart';
import 'download_models.dart';
import 'download_queue.dart';
import 'download_repository.dart';
import 'download_transfer.dart';

/// Downloads catalog files on the user's request, at most [maxConcurrent] at
/// a time, into `audio/<packId>/<fileName>` under the [FileStore] (via a
/// `.part` file that is renamed once verified). State lives in
/// `download_items`, so an interrupted download can be resumed after a
/// restart; nothing starts without a call from the user.
///
/// Every request for a file (enqueue/resume, pause, cancel/delete) bumps that
/// file's generation synchronously; a request that is still awaiting the
/// database gives up once a newer one exists, so the last call wins.
class DownloadService {
  DownloadService({
    required http.Client client,
    required FileStore files,
    required DownloadRepository repo,
    required this.catalog,
    this.maxConcurrent = 2,
    this.stallTimeout = const Duration(seconds: 30),
    this.progressInterval = const Duration(milliseconds: 500),
    this.onFileDone,
    this.onFileRemoved,
  }) : _client = client,
       _files = files,
       _repo = repo {
    _queue = DownloadQueue(
      maxConcurrent: maxConcurrent,
      createTransfer: _transferFor,
      onFinished: _finished,
    );
  }

  /// Root directory of downloaded files in the store.
  static const audioDir = 'audio';

  final http.Client _client;
  final FileStore _files;
  final DownloadRepository _repo;
  final Catalog catalog;
  final int maxConcurrent;
  final Duration stallTimeout;
  final Duration progressInterval;

  /// Called once a file is verified and in place (relative store path).
  final void Function(CatalogPack, CatalogFile, String relativePath)?
  onFileDone;

  /// Called when a downloaded file is deleted.
  final void Function(CatalogFile)? onFileRemoved;

  late final DownloadQueue _queue;
  final Map<String, int> _generation = {};

  /// Deletes in progress; an enqueue of the same id waits for them.
  final Map<String, Future<void>> _deleting = {};
  bool _disposed = false;

  static String pathFor(CatalogPack pack, CatalogFile file) =>
      '$audioDir/${pack.id}/${file.fileName}';

  int _bump(String id) => _generation[id] = (_generation[id] ?? 0) + 1;

  /// Queues [fileId] (a no-op if it is queued, running, or done and present;
  /// a file already on disk with the catalog size is just marked done).
  /// Also resumes a paused or failed file, after a pause that is still
  /// draining; after a cancel or delete still in progress it starts afresh
  /// once that has finished. Throws [ArgumentError] for an unknown id.
  Future<void> enqueueFile(String fileId) async {
    final (pack, file) = catalog.requireFile(fileId);
    final running = _queue.active(fileId);
    if (_disposed ||
        _queue.isWaiting(fileId) ||
        (running != null && !running.aborted)) {
      return;
    }
    final gen = _bump(fileId);
    bool superseded() => _disposed || _generation[fileId] != gen;
    if (running != null) await _queue.drained(fileId);
    await _deleting[fileId];

    final path = pathFor(pack, file);
    final existing = await _repo.get(fileId);
    if (superseded()) return;
    if (await _files.exists(path)) {
      if (existing?.status == DownloadStatus.done) return;
      final size = await _files.size(path);
      if (size == file.sizeBytes && !superseded()) {
        await _repo.record(pack.id, file, path, DownloadStatus.done, size);
        _notify(() => onFileDone?.call(pack, file, path));
        return;
      }
    }
    final partSize = await _files.size('$path.part');
    if (superseded()) return;
    await _repo.record(pack.id, file, path, DownloadStatus.queued, partSize);
    if (!superseded()) _queue.add(fileId);
  }

  /// Queues every file of [packId] in catalog order.
  Future<void> enqueuePack(String packId) async {
    for (final f in catalog.requirePack(packId).files) {
      await enqueueFile(f.id);
    }
  }

  /// Resumes a paused or failed file.
  Future<void> resume(String fileId) => enqueueFile(fileId);

  /// Resumes the paused and failed files of [packId].
  Future<void> resumePack(String packId) async {
    final ids = _ids(packId);
    const resumable = {DownloadStatus.paused, DownloadStatus.failed};
    for (final item in await _repo.getAll()) {
      if (ids.contains(item.fileId) && resumable.contains(item.status)) {
        await enqueueFile(item.fileId);
      }
    }
  }

  /// Pauses a queued or running file, keeping its `.part`.
  Future<void> pause(String fileId) => _pauseAll({fileId});

  Future<void> pausePack(String packId) => _pauseAll(_ids(packId));

  /// Stops a download and removes its `.part` and row. A file that already
  /// finished is deleted as by [deleteFile].
  Future<void> cancel(String fileId) => _deleteAll({fileId});

  /// Deletes a file (finished or partial), its row, and its track (through
  /// [onFileRemoved]).
  Future<void> deleteFile(String fileId) => _deleteAll({fileId});

  /// Deletes every file of [packId] and the pack's directory.
  Future<void> deletePack(String packId) async {
    final pack = catalog.requirePack(packId);
    await _deleteAll(_ids(packId), dir: '$audioDir/${pack.id}');
  }

  Future<void> _pauseAll(Set<String> ids) async {
    final gens = {for (final id in ids) id: _bump(id)};
    _queue.removeWaiting(ids);
    await _queue.stop(ids);
    const unfinished = {DownloadStatus.queued, DownloadStatus.running};
    for (final id in ids) {
      if (_generation[id] != gens[id]) continue; // resumed meanwhile
      final item = await _repo.get(id);
      if (item != null && unfinished.contains(item.status)) {
        await _repo.setStatus(id, DownloadStatus.paused);
      }
    }
  }

  /// Deletes [ids] (and [dir]). Registered in [_deleting] synchronously, so
  /// a re-enqueue issued meanwhile runs after the delete, not under it.
  Future<void> _deleteAll(Set<String> ids, {String? dir}) {
    ids.forEach(_bump);
    _queue.removeWaiting(ids);
    final done = _deleteNow(ids, dir);
    for (final id in ids) {
      _deleting[id] = done;
    }
    return done.whenComplete(() {
      for (final id in ids) {
        if (identical(_deleting[id], done)) _deleting.remove(id);
      }
    });
  }

  Future<void> _deleteNow(Set<String> ids, String? dir) async {
    await _queue.stop(ids);
    for (final id in ids) {
      final (pack, file) = catalog.requireFile(id);
      final path = pathFor(pack, file);
      final hadFile = await _files.exists(path);
      final item = await _repo.get(id);
      await _files.delete('$path.part');
      await _files.delete(path);
      await _repo.delete(id);
      if (hadFile || item?.status == DownloadStatus.done) {
        _notify(() => onFileRemoved?.call(file));
      }
    }
    if (dir != null) await _files.deleteDir(dir);
  }

  /// Call once at startup: downloads left running or queued by a previous
  /// session become paused. Issues no network request.
  Future<void> restore() => _repo.pauseUnfinished();

  /// Bytes used by downloaded (and partial) files.
  Future<int> usedBytes() => _files.usedBytes(audioDir);

  /// Completes when nothing is queued or running.
  Future<void> whenIdle() => _queue.whenIdle();

  /// Aborts transfers without changing their rows (the next [restore] marks
  /// them paused).
  Future<void> dispose() async {
    _disposed = true;
    await _queue.close();
  }

  DownloadTransfer _transferFor(String fileId) {
    final (pack, file) = catalog.requireFile(fileId);
    return DownloadTransfer(
      client: _client,
      files: _files,
      repo: _repo,
      file: file,
      relativePath: pathFor(pack, file),
      stallTimeout: stallTimeout,
      progressInterval: progressInterval,
    );
  }

  void _finished(String fileId, TransferOutcome outcome) {
    if (outcome != TransferOutcome.done) return;
    final (pack, file) = catalog.requireFile(fileId);
    _notify(() => onFileDone?.call(pack, file, pathFor(pack, file)));
  }

  void _notify(void Function() callback) {
    try {
      callback();
    } catch (e, st) {
      developer.log(
        'Callback failed',
        name: 'downloads',
        error: e,
        stackTrace: st,
      );
    }
  }

  Set<String> _ids(String packId) =>
      catalog.requirePack(packId).files.map((f) => f.id).toSet();
}
