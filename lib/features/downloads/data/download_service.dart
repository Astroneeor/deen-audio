import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/storage/file_store.dart';
import 'catalog.dart';
import 'download_callbacks.dart';
import 'download_removal.dart';
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
/// database gives up once a newer one exists, so the last call wins. A pack
/// pause or delete likewise bumps the pack's generation, which stops an
/// [enqueuePack] still walking that pack.
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
    this.registeredFiles,
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
  final FileDoneCallback? onFileDone;

  /// Called when a downloaded file is deleted.
  final void Function(CatalogFile)? onFileRemoved;

  /// Which files already have a Library track: a finished reciter file
  /// without one gets [onFileDone] again (on enqueue and at [restore]).
  final RegisteredFilesQuery? registeredFiles;

  late final DownloadQueue _queue;
  final Map<String, int> _generation = {};
  final Map<String, int> _packGeneration = {};
  late final _remover = DownloadRemover(
    catalog: catalog,
    files: _files,
    repo: _repo,
    pathFor: pathFor,
    onRemoved: onFileRemoved,
  );
  bool _disposed = false;

  static String pathFor(CatalogPack pack, CatalogFile file) =>
      '$audioDir/${pack.id}/${file.fileName}';

  int _bump(String id) => _generation[id] = (_generation[id] ?? 0) + 1;

  void _bumpPack(String? id) {
    if (id != null) _packGeneration.update(id, (g) => g + 1, ifAbsent: () => 1);
  }

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
    await _remover.pending(fileId);

    final path = pathFor(pack, file);
    final existing = await _repo.get(fileId);
    if (superseded()) return;
    if (await _files.exists(path)) {
      if (existing?.status == DownloadStatus.done) {
        return _reRegister([fileId]);
      }
      final size = await _files.size(path);
      if (size == file.sizeBytes && !superseded()) {
        await _repo.record(pack.id, file, path, DownloadStatus.done, size);
        runLogged(() => onFileDone?.call(pack, file, path));
        return;
      }
    }
    final partSize = await _files.size('$path.part');
    if (superseded()) return;
    await _repo.record(pack.id, file, path, DownloadStatus.queued, partSize);
    if (!superseded()) _queue.add(fileId);
  }

  /// Queues every file of [packId] in catalog order, stopping if the pack
  /// is paused or deleted meanwhile.
  Future<void> enqueuePack(String packId) async {
    final files = catalog.requirePack(packId).files;
    final gen = _packGeneration[packId];
    for (final f in files) {
      if (_packGeneration[packId] != gen) return;
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

  Future<void> pausePack(String packId) =>
      _pauseAll(_ids(packId), pack: packId);

  /// Stops a download and removes its `.part` and row. A file that already
  /// finished is deleted as by [deleteFile].
  Future<void> cancel(String fileId) => _deleteAll({fileId});

  /// Deletes a file (finished or partial), its row, and its track (through
  /// [onFileRemoved]).
  Future<void> deleteFile(String fileId) => _deleteAll({fileId});

  /// Deletes every file of [packId] and the pack's directory.
  Future<void> deletePack(String packId) async {
    final pack = catalog.requirePack(packId);
    await _deleteAll(_ids(packId), dir: '$audioDir/${pack.id}', pack: packId);
  }

  /// [pack], when given, is the pack being paused as a whole.
  Future<void> _pauseAll(Set<String> ids, {String? pack}) async {
    _bumpPack(pack);
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

  /// Deletes [ids] (and [dir]); see [DownloadRemover.remove].
  Future<void> _deleteAll(Set<String> ids, {String? dir, String? pack}) {
    _bumpPack(pack);
    ids.forEach(_bump);
    _queue.removeWaiting(ids);
    return _remover.remove(ids, dir: dir, stop: () => _queue.stop(ids));
  }

  /// Call once at startup: downloads left running or queued by a previous
  /// session become paused, and finished reciter files missing their Library
  /// track get it back. Issues no network request.
  Future<void> restore() async {
    await _repo.pauseUnfinished();
    await _reRegister([
      for (final item in await _repo.getAll())
        if (item.status == DownloadStatus.done) item.fileId,
    ]);
  }

  Future<void> _reRegister(List<String> doneIds) => reRegisterMissing(
    doneIds,
    catalog,
    registeredFiles,
    onFileDone,
    pathFor: pathFor,
  );

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
    runLogged(() => onFileDone?.call(pack, file, pathFor(pack, file)));
  }

  Set<String> _ids(String packId) =>
      catalog.requirePack(packId).files.map((f) => f.id).toSet();
}
