import 'dart:async';
import 'dart:developer' as developer;

import 'download_transfer.dart';

/// Runs [DownloadTransfer]s first-in first-out, at most [maxConcurrent] at a
/// time. Knows nothing about the database; [DownloadService] decides what
/// to add, stop and record.
class DownloadQueue {
  DownloadQueue({
    required this.maxConcurrent,
    required this.createTransfer,
    required this.onFinished,
  });

  final int maxConcurrent;
  final DownloadTransfer Function(String fileId) createTransfer;

  /// Called after a transfer ends (before its slot is reused).
  final void Function(String fileId, TransferOutcome outcome) onFinished;

  final List<String> _waiting = [];
  final Map<String, DownloadTransfer> _active = {};
  final Map<String, Future<void>> _finished = {};
  Completer<void>? _idle;
  bool _closed = false;

  bool isWaiting(String fileId) => _waiting.contains(fileId);

  /// The running transfer of [fileId], or null.
  DownloadTransfer? active(String fileId) => _active[fileId];

  void add(String fileId) {
    if (_closed || isWaiting(fileId) || _active.containsKey(fileId)) return;
    _waiting.add(fileId);
    _pump();
  }

  /// Removes [ids] from the waiting list; returns those that were waiting.
  Set<String> removeWaiting(Set<String> ids) {
    final removed = ids.where(_waiting.contains).toSet();
    _waiting.removeWhere(ids.contains);
    _checkIdle();
    return removed;
  }

  /// Completes when the transfer of [fileId] (if any) has fully ended.
  /// Never completes with an error.
  Future<void> drained(String fileId) => _finished[fileId] ?? Future.value();

  /// Aborts the running transfers among [ids] and waits for them to end.
  Future<void> stop(Iterable<String> ids) async {
    final running = ids.where(_active.containsKey).toList();
    for (final id in running) {
      _active[id]!.abort();
    }
    await Future.wait(running.map(drained));
  }

  /// Completes when nothing is waiting or running.
  Future<void> whenIdle() {
    if (_waiting.isEmpty && _active.isEmpty) return Future.value();
    return (_idle ??= Completer<void>()).future;
  }

  /// Stops everything and accepts no more work.
  Future<void> close() async {
    _closed = true;
    _waiting.clear();
    await stop(_active.keys.toList());
    _checkIdle();
  }

  void _pump() {
    while (!_closed && _active.length < maxConcurrent && _waiting.isNotEmpty) {
      _start(_waiting.removeAt(0));
    }
    _checkIdle();
  }

  void _start(String fileId) {
    final transfer = createTransfer(fileId);
    _active[fileId] = transfer;
    _finished[fileId] = () async {
      try {
        onFinished(fileId, await transfer.run());
      } catch (e, st) {
        developer.log(
          'Transfer of $fileId ended with an error',
          name: 'downloads',
          error: e,
          stackTrace: st,
        );
      } finally {
        if (identical(_active[fileId], transfer)) {
          _active.remove(fileId);
          _finished.remove(fileId);
        }
        _pump();
      }
    }();
  }

  void _checkIdle() {
    final idle = _idle;
    if (idle != null && _waiting.isEmpty && _active.isEmpty) {
      _idle = null;
      idle.complete();
    }
  }
}
