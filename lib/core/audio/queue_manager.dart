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

  int? get _nextIndex {
    if (queue.isEmpty) return null;
    if (repeatMode == RepeatMode.one) return currentIndex;
    final n = currentIndex + 1;
    if (n < queue.length) return n;
    if (repeatMode == RepeatMode.all) return 0;
    return null;
  }

  int? get _prevIndex {
    if (queue.isEmpty) return null;
    if (repeatMode == RepeatMode.one) return currentIndex;
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
    final q = state.shuffleEnabled ? _shuffled(tracks, startIndex) : tracks;
    _setState(state.copyWith(
      queue: q,
      currentIndex: state.shuffleEnabled ? 0 : startIndex,
    ));
  }

  void addTrack(Track track) {
    _originalQueue.add(track);
    _setState(state.copyWith(queue: [...state.queue, track]));
  }

  /// Advance to next track. Returns new index or null if queue ended.
  int? next() {
    final idx = state._nextIndex;
    if (idx == null) return null;
    _setState(state.copyWith(currentIndex: idx));
    return idx;
  }

  /// Move to previous track. Returns new index or null if at start.
  int? previous() {
    final idx = state._prevIndex;
    if (idx == null) return null;
    _setState(state.copyWith(currentIndex: idx));
    return idx;
  }

  void jumpTo(int index) {
    _setState(state.copyWith(
      currentIndex: index.clamp(0, state.queue.length - 1),
    ));
  }

  void setShuffleEnabled(bool enabled) {
    if (enabled == state.shuffleEnabled) return;
    if (enabled) {
      final shuffled = _shuffled(List.from(_originalQueue), state.currentIndex);
      _setState(state.copyWith(queue: shuffled, currentIndex: 0, shuffleEnabled: true));
    } else {
      final current = state.currentTrack;
      final restored = current == null
          ? 0
          : _originalQueue.indexWhere((t) => t.id == current.id);
      _setState(state.copyWith(
        queue: List.from(_originalQueue),
        currentIndex: restored.clamp(0, _originalQueue.length - 1),
        shuffleEnabled: false,
      ));
    }
  }

  void setRepeatMode(RepeatMode mode) => _setState(state.copyWith(repeatMode: mode));

  void clear() {
    _originalQueue = [];
    _setState(const QueueState());
  }

  List<Track> _shuffled(List<Track> tracks, int pivot) {
    if (tracks.isEmpty) return tracks;
    final clamp = pivot.clamp(0, tracks.length - 1);
    final head = tracks[clamp];
    final tail = List<Track>.from(tracks)..removeAt(clamp);
    tail.shuffle();
    return [head, ...tail];
  }

  void dispose() => _subject.close();
}
