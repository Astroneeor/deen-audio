import 'dart:async';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../core/storage/file_store.dart';
import 'catalog.dart';
import 'download_models.dart';
import 'download_repository.dart';
import 'download_transfer.dart';

/// Downloads catalog files on the user's request, at most [maxConcurrent] at
/// a time, into `audio/<packId>/<fileName>` under the [FileStore] (via a
/// `.part` file that is renamed once verified). State lives in
/// `download_items`, so an interrupted download can be resumed after a
/// restart; nothing starts without a call from the user.
class DownloadService {
  DownloadService({
    required http.Client client,
    required FileStore files,
    required DownloadRepository repo,
    required this.catalog,
    this.maxConcurrent = 2,
    this.onFileDone,
    this.onFileRemoved,
  }) : _client = client,
       _files = files,
       _repo = repo;

  /// Root directory of downloaded files in the store.
  static const audioDir = 'audio';

  final http.Client _client;
  final FileStore _files;
  final DownloadRepository _repo;
  final Catalog catalog;
  final int maxConcurrent;

  /// Called once a file is verified and in place (relative store path).
  final void Function(CatalogPack, CatalogFile, String relativePath)?
  onFileDone;

  /// Called when a downloaded file is deleted.
  final void Function(CatalogFile)? onFileRemoved;

  final List<String> _queue = [];
  final Map<String, DownloadTransfer> _active = {};
  final Map<String, Future<void>> _finished = {};
  Completer<void>? _idle;
  bool _disposed = false;

  static String pathFor(CatalogPack pack, CatalogFile file) =>
      '$audioDir/${pack.id}/${file.fileName}';

  /// Queues [fileId] (a no-op if it is queued, running, or done and present).
  /// Also resumes a paused or failed file. Throws [ArgumentError] for an id
  /// that is not in the catalog.
  Future<void> enqueueFile(String fileId) async {
    final (pack, file) = catalog.requireFile(fileId);
    if (_disposed || _queue.contains(fileId) || _active.containsKey(fileId)) {
      return;
    }
    final path = pathFor(pack, file);
    final existing = await _repo.get(fileId);
    if (existing?.status == DownloadStatus.done && await _files.exists(path)) {
      return;
    }
    await _repo.upsert(
      DownloadItem(
        fileId: fileId,
        packId: pack.id,
        status: DownloadStatus.queued,
        bytesDone: await _files.size('$path.part'),
        bytesTotal: file.sizeBytes,
        relativePath: path,
      ),
      url: file.url,
      checksum: file.checksum,
    );
    if (_queue.contains(fileId) || _active.containsKey(fileId)) return;
    _queue.add(fileId);
    _pump();
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
    await _deleteAll(_ids(packId));
    await _files.deleteDir('$audioDir/${pack.id}');
  }

  Future<void> _pauseAll(Set<String> ids) async {
    final dequeued = ids.where(_queue.contains).toList();
    _queue.removeWhere(ids.contains);
    await _stop(ids);
    for (final id in ids) {
      final item = await _repo.get(id);
      if (dequeued.contains(id) || item?.status == DownloadStatus.running) {
        await _repo.setStatus(id, DownloadStatus.paused);
      }
    }
    _checkIdle();
  }

  Future<void> _deleteAll(Set<String> ids) async {
    _queue.removeWhere(ids.contains);
    await _stop(ids);
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
    _checkIdle();
  }

  /// Aborts the running transfers among [ids] and waits for them to end.
  Future<void> _stop(Set<String> ids) async {
    final running = ids.where(_active.containsKey).toList();
    for (final id in running) {
      _active[id]!.abort();
    }
    await Future.wait(running.map((id) => _finished[id] ?? Future.value()));
  }

  /// Call once at startup: downloads left running by a previous session
  /// become paused. Issues no network request.
  Future<void> restore() => _repo.resetRunningToPaused();

  /// Bytes used by downloaded (and partial) files.
  Future<int> usedBytes() => _files.usedBytes(audioDir);

  /// Completes when nothing is queued or running.
  Future<void> whenIdle() {
    if (_queue.isEmpty && _active.isEmpty) return Future.value();
    return (_idle ??= Completer<void>()).future;
  }

  /// Aborts transfers without changing their rows (the next [restore] marks
  /// them paused).
  Future<void> dispose() async {
    _disposed = true;
    _queue.clear();
    await _stop(_active.keys.toSet());
    _checkIdle();
  }

  void _pump() {
    while (!_disposed && _active.length < maxConcurrent && _queue.isNotEmpty) {
      _start(_queue.removeAt(0));
    }
    _checkIdle();
  }

  void _start(String fileId) {
    final (pack, file) = catalog.requireFile(fileId);
    final path = pathFor(pack, file);
    final transfer = DownloadTransfer(
      client: _client,
      files: _files,
      repo: _repo,
      file: file,
      relativePath: path,
    );
    _active[fileId] = transfer;
    _finished[fileId] = transfer
        .run()
        .then((outcome) {
          if (outcome == TransferOutcome.done) {
            _notify(() => onFileDone?.call(pack, file, path));
          }
        })
        .whenComplete(() {
          if (identical(_active[fileId], transfer)) {
            _active.remove(fileId);
            _finished.remove(fileId);
          }
          _pump();
        });
  }

  void _checkIdle() {
    final idle = _idle;
    if (idle != null && _queue.isEmpty && _active.isEmpty) {
      _idle = null;
      idle.complete();
    }
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
