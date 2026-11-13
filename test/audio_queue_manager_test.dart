import 'package:deen_audio/core/audio/queue_manager.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:flutter_test/flutter_test.dart';

Track _track(int id) => Track()
  ..id = id
  ..title = 'Track $id'
  ..type = TrackType.nasheed
  ..filePath = '/music/$id.mp3';

List<Track> _tracks(int n) => List.generate(n, (i) => _track(i + 1));

List<int> _ids(QueueState s) => s.queue.map((t) => t.id).toList();

void main() {
  late QueueManager q;

  setUp(() => q = QueueManager());
  tearDown(() => q.dispose());

  group('setQueue', () {
    test('starts at the requested index', () {
      q.setQueue(_tracks(4), startIndex: 2);
      expect(q.state.currentIndex, 2);
      expect(q.state.currentTrack!.id, 3);
    });

    test('clamps an out-of-range start index', () {
      q.setQueue(_tracks(3), startIndex: 10);
      expect(q.state.currentIndex, 2);
      expect(q.next(), isNull);

      q.setQueue(_tracks(3), startIndex: -4);
      expect(q.state.currentIndex, 0);
    });

    test('does not alias the caller\'s list', () {
      final source = _tracks(3);
      q.setQueue(source);
      source.clear();
      expect(q.state.queue, hasLength(3));
      expect(q.next(), 1);
    });

    test('with shuffle on, puts the chosen track first', () {
      q.setShuffleEnabled(true);
      q.setQueue(_tracks(20), startIndex: 7);
      expect(q.state.currentIndex, 0);
      expect(q.state.currentTrack!.id, 8);
      expect(_ids(q.state).toSet(), _ids(QueueState(queue: _tracks(20))).toSet());
    });

    test('empty queue has no current track and nowhere to go', () {
      q.setQueue([]);
      expect(q.state.currentTrack, isNull);
      expect(q.next(), isNull);
      expect(q.previous(), isNull);
      expect(q.onTrackCompleted(), isNull);
    });
  });

  group('next / previous at the ends', () {
    test('repeat none: stops at both ends without moving', () {
      q.setQueue(_tracks(3));
      expect(q.previous(), isNull);
      expect(q.state.currentIndex, 0);
      expect(q.next(), 1);
      expect(q.next(), 2);
      expect(q.next(), isNull);
      expect(q.state.currentIndex, 2);
      expect(q.state.hasNext, isFalse);
      expect(q.state.hasPrevious, isTrue);
    });

    test('repeat all: wraps in both directions', () {
      q.setQueue(_tracks(3));
      q.setRepeatMode(RepeatMode.all);
      expect(q.previous(), 2);
      expect(q.next(), 0);
      expect(q.state.hasNext, isTrue);
      expect(q.state.hasPrevious, isTrue);
    });

    test('repeat all on a single track replays it', () {
      q.setQueue(_tracks(1));
      q.setRepeatMode(RepeatMode.all);
      expect(q.next(), 0);
      expect(q.onTrackCompleted(), 0);
    });
  });

  group('repeat one', () {
    test('a finished track repeats itself', () {
      q.setQueue(_tracks(3), startIndex: 1);
      q.setRepeatMode(RepeatMode.one);
      expect(q.onTrackCompleted(), 1);
      expect(q.onTrackCompleted(), 1);
    });

    test('manual skip still moves to the neighbouring track', () {
      q.setQueue(_tracks(3), startIndex: 1);
      q.setRepeatMode(RepeatMode.one);
      expect(q.next(), 2);
      expect(q.previous(), 1);
      expect(q.previous(), 0);
    });

    test('a finished last track repeats rather than ending the queue', () {
      q.setQueue(_tracks(2), startIndex: 1);
      q.setRepeatMode(RepeatMode.one);
      expect(q.onTrackCompleted(), 1);
    });
  });

  group('onTrackCompleted', () {
    test('repeat none: advances, then ends the queue', () {
      q.setQueue(_tracks(2));
      expect(q.onTrackCompleted(), 1);
      expect(q.onTrackCompleted(), isNull);
    });

    test('repeat all: wraps to the first track', () {
      q.setQueue(_tracks(2), startIndex: 1);
      q.setRepeatMode(RepeatMode.all);
      expect(q.onTrackCompleted(), 0);
    });
  });

  group('shuffle', () {
    test('enabling keeps the current track playing and keeps every track', () {
      q.setQueue(_tracks(30), startIndex: 12);
      q.setShuffleEnabled(true);
      expect(q.state.shuffleEnabled, isTrue);
      expect(q.state.currentIndex, 0);
      expect(q.state.currentTrack!.id, 13);
      expect(_ids(q.state), hasLength(30));
      expect(_ids(q.state).toSet(), hasLength(30));
      // 29! orderings: an unchanged tail means shuffle did nothing.
      expect(_ids(q.state).sublist(1),
          isNot(List.generate(30, (i) => i + 1)..remove(13)));
    });

    test('disabling restores the original order at the current track', () {
      q.setQueue(_tracks(30), startIndex: 12);
      q.setShuffleEnabled(true);
      q.next();
      q.next();
      final playing = q.state.currentTrack!;
      q.setShuffleEnabled(false);
      expect(_ids(q.state), List.generate(30, (i) => i + 1));
      expect(q.state.currentTrack, same(playing));
      expect(q.state.currentIndex, playing.id - 1);
    });

    test('disabling finds the current track even when ids collide', () {
      // Tracks that were never persisted all share the default id 0.
      final tracks = List.generate(10, (i) => Track()
        ..title = 'T$i'
        ..type = TrackType.quran
        ..filePath = '/q/$i.mp3');
      q.setQueue(tracks, startIndex: 6);
      q.setShuffleEnabled(true);
      q.setShuffleEnabled(false);
      expect(q.state.currentIndex, 6);
      expect(q.state.currentTrack, same(tracks[6]));
    });

    test('toggling with an empty queue does not throw', () {
      q.setShuffleEnabled(true);
      q.setShuffleEnabled(false);
      expect(q.state.shuffleEnabled, isFalse);
      expect(q.state.currentTrack, isNull);
    });

    test('a track added while shuffled survives un-shuffling', () {
      q.setQueue(_tracks(3));
      q.setShuffleEnabled(true);
      q.addTrack(_track(99));
      q.setShuffleEnabled(false);
      expect(_ids(q.state), [1, 2, 3, 99]);
    });
  });

  group('jumpTo / clear / stream', () {
    test('jumpTo clamps and tolerates an empty queue', () {
      q.jumpTo(3);
      expect(q.state.currentIndex, 0);
      q.setQueue(_tracks(3));
      q.jumpTo(9);
      expect(q.state.currentIndex, 2);
    });

    test('clear empties the queue but keeps shuffle and repeat settings', () {
      q.setQueue(_tracks(3), startIndex: 1);
      q.setShuffleEnabled(true);
      q.setRepeatMode(RepeatMode.all);
      q.clear();
      expect(q.state.queue, isEmpty);
      expect(q.state.currentIndex, 0);
      expect(q.state.shuffleEnabled, isTrue);
      expect(q.state.repeatMode, RepeatMode.all);
    });

    test('new subscribers immediately receive the current state', () async {
      q.setQueue(_tracks(2), startIndex: 1);
      final s = await q.stream.first;
      expect(s.currentIndex, 1);
    });
  });
}
