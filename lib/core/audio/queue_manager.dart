import 'package:rxdart/rxdart.dart';

import '../models/track.dart';

enum RepeatMode { none, one, all }

/// Immutable snapshot of the queue at a point in time.
class QueueState {
  final List<Track> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;

  const QueueState({
    this.queue = const [],
    this.currentIndex = 0,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.none,
  });

  Track? get currentTrack =>
      queue.isEmpty ? null : queue[currentIndex.clamp(0, queue.length - 1)];

  bool get hasNext => _nextIndex != null;
  bool get hasPrevious => _prevIndex != null;

  /// Target of a manual "next". Repeat-one does not pin the user to the
  /// current track here — it only applies when a track finishes on its own.
  int? get _nextIndex {
    if (queue.isEmpty) return null;
    final n = currentIndex + 1;
    if (n < queue.length) return n;
    if (repeatMode == RepeatMode.all) return 0;
    return null;
  }

  /// Target once the current track has played to its end.
  int? get _completedIndex {
    if (queue.isEmpty) return null;
    if (repeatMode == RepeatMode.one) return currentIndex;
    return _nextIndex;
  }

  int? get _prevIndex {
    if (queue.isEmpty) return null;
    final p = currentIndex - 1;
    if (p >= 0) return p;
    if (repeatMode == RepeatMode.all) return queue.length - 1;
    return null;
  }

  QueueState copyWith({
    List<Track>? queue,
    int? currentIndex,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
  }) {
    return QueueState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}

/// Manages the playback queue: ordering, shuffle, and repeat.
/// Pure Dart — no Flutter dependencies.
/// Exposes a [BehaviorSubject] so new listeners immediately receive
/// the current state without waiting for the next change.
class QueueManager {
  final _subject = BehaviorSubject<QueueState>.seeded(const QueueState());
  List<Track> _originalQueue = [];

  Stream<QueueState> get stream => _subject.stream;
  QueueState get state => _subject.value;

  void _setState(QueueState s) => _subject.add(s);

  void setQueue(List<Track> tracks, {int startIndex = 0}) {
    _originalQueue = List.from(tracks);
    final start = _clampIndex(startIndex, tracks.length);
    final q = state.shuffleEnabled
        ? _shuffled(tracks, start)
        : List<Track>.from(tracks);
    _setState(state.copyWith(
      queue: q,
      currentIndex: state.shuffleEnabled ? 0 : start,
    ));
  }

  void addTrack(Track track) {
    _originalQueue.add(track);
    _setState(state.copyWith(queue: [...state.queue, track]));
  }

  /// Manual skip to the next track. Returns new index or null at the end.
  int? next() => _moveTo(state._nextIndex);

  /// Call when the current track finished playing by itself. Honours
  /// repeat-one (same index again). Returns null when the queue has ended.
  int? onTrackCompleted() => _moveTo(state._completedIndex);

  /// Move to previous track. Returns new index or null if at start.
  int? previous() => _moveTo(state._prevIndex);

  int? _moveTo(int? idx) {
    if (idx == null) return null;
    _setState(state.copyWith(currentIndex: idx));
    return idx;
  }

  void jumpTo(int index) {
    _setState(state.copyWith(
      currentIndex: _clampIndex(index, state.queue.length),
    ));
  }

  void setShuffleEnabled(bool enabled) {
    if (enabled == state.shuffleEnabled) return;
    if (enabled) {
      final shuffled = _shuffled(List.from(_originalQueue), state.currentIndex);
      _setState(state.copyWith(queue: shuffled, currentIndex: 0, shuffleEnabled: true));
    } else {
      final current = state.currentTrack;
      // Match by identity: ids collide for unsaved tracks and for a track
      // that was queued twice.
      final restored = _originalQueue.indexWhere((t) => identical(t, current));
      _setState(state.copyWith(
        queue: List.from(_originalQueue),
        currentIndex: _clampIndex(restored, _originalQueue.length),
        shuffleEnabled: false,
      ));
    }
  }

  void setRepeatMode(RepeatMode mode) => _setState(state.copyWith(repeatMode: mode));

  /// Empties the queue. Shuffle and repeat are user settings and survive.
  void clear() {
    _originalQueue = [];
    _setState(state.copyWith(queue: const [], currentIndex: 0));
  }

  /// Clamps [index] into `0..length-1`; 0 for an empty list.
  int _clampIndex(int index, int length) =>
      length == 0 ? 0 : index.clamp(0, length - 1);

  List<Track> _shuffled(List<Track> tracks, int pivot) {
    if (tracks.isEmpty) return [];
    final clamp = _clampIndex(pivot, tracks.length);
    final head = tracks[clamp];
    final tail = List<Track>.from(tracks)..removeAt(clamp);
    tail.shuffle();
    return [head, ...tail];
  }

  void dispose() => _subject.close();
}
