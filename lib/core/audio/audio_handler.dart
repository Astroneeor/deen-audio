import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track.dart';
import 'queue_manager.dart';
import 'track_source.dart';

/// Bridges just_audio with audio_service, enabling OS media controls:
/// Linux MPRIS, Windows SMTC, macOS Media Center.
///
/// [AudioPlayerService] is the public API. This class owns the [AudioPlayer]
/// and is the only place in the codebase that imports just_audio directly.
class DeenAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _queue = QueueManager();

  // ── Streams exposed to AudioPlayerService (no just_audio types leak out) ──

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get volumeStream => _player.volumeStream;
  QueueManager get queueManager => _queue;

  DeenAudioHandler() {
    // Pipe just_audio playback events → audio_service playback state broadcast
    _player.playbackEventStream.listen(
      (event) => playbackState.add(_toPlaybackState(event)),
      onError: (Object e, StackTrace st) {
        // Surface error but keep service running
        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ));
      },
    );

    // Auto-advance queue when track finishes
    _player.processingStateStream.listen((ps) {
      if (ps == ProcessingState.completed) _onCompleted();
    });
  }

  // ── Public API (called by AudioPlayerService) ─────────────────────────────

  Future<void> playTrack(Track track) async {
    _queue.setQueue([track]);
    await _loadCurrent();
    await _player.play();
  }

  Future<void> playQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queue.setQueue(tracks, startIndex: startIndex);
    await _loadCurrent();
    await _player.play();
  }

  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0.0, 1.0));

  // ── BaseAudioHandler overrides for shuffle / repeat ───────────────────────
  // These are also called by the OS (Linux MPRIS, Windows SMTC, etc.)
  // so we keep the audio_service signatures and convert to our own enums.

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _queue.setShuffleEnabled(shuffleMode != AudioServiceShuffleMode.none);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _queue.setRepeatMode(switch (repeatMode) {
      AudioServiceRepeatMode.none => RepeatMode.none,
      AudioServiceRepeatMode.one => RepeatMode.one,
      AudioServiceRepeatMode.all || AudioServiceRepeatMode.group => RepeatMode.all,
    });
  }

  // ── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_queue.next() != null) {
      await _loadCurrent();
      await _player.play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Restart current track if more than 3 s in; otherwise go back
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_queue.previous() != null) {
      await _loadCurrent();
      await _player.play();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  bool _completing = false;

  Future<void> _onCompleted() async {
    if (_completing) return;
    _completing = true;
    try {
      if (_queue.next() != null) {
        await _loadCurrent();
        await _player.play();
      } else {
        _queue.clear();
        await stop();
      }
    } finally {
      _completing = false;
    }
  }

  Future<void> _loadCurrent() async {
    final track = _queue.state.currentTrack;
    if (track == null) return;
    final src = await LocalTrackSource(track.filePath).toAudioSource();
    await _player.setAudioSource(src);
    mediaItem.add(_toMediaItem(track));
    queue.add(_queue.state.queue.map(_toMediaItem).toList());
  }

  PlaybackState _toPlaybackState(PlaybackEvent event) {
    final playing = _player.playing;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  MediaItem _toMediaItem(Track t) => MediaItem(
        id: t.filePath,
        title: t.title,
        artist: t.artist,
        duration: t.duration > 0 ? Duration(milliseconds: t.duration) : null,
      );

  Future<void> dispose() async {
    _queue.dispose();
    await _player.dispose();
  }
}
