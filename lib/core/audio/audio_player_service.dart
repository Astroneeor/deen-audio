import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/track.dart';
import 'audio_handler.dart';
import 'queue_manager.dart';

/// Central audio engine. The ONLY public interface for playback in the app.
/// UI code interacts exclusively with this service via Riverpod providers;
/// nothing outside core/audio/ touches just_audio or DeenAudioHandler directly.
class AudioPlayerService {
  final DeenAudioHandler _handler;

  const AudioPlayerService(this._handler);

  // ── Streams ───────────────────────────────────────────────────────────────

  /// OS-level playback state (playing, paused, buffering…).
  Stream<PlaybackState> get playbackStateStream => _handler.playbackState;

  /// Currently playing track metadata (title, artist, duration).
  Stream<MediaItem?> get currentTrackStream => _handler.mediaItem;

  /// Position within the current track, updated ~every 200 ms.
  Stream<Duration> get positionStream => _handler.positionStream;

  /// Total duration of the loaded track (null while loading).
  Stream<Duration?> get durationStream => _handler.durationStream;

  /// Current volume level (0.0–1.0).
  Stream<double> get volumeStream => _handler.volumeStream;

  /// Queue state: list, index, shuffle flag, repeat mode.
  Stream<QueueState> get queueStateStream => _handler.queueManager.stream;

  // ── Playback controls ─────────────────────────────────────────────────────

  Future<void> playTrack(Track track) => _handler.playTrack(track);

  Future<void> playQueue(List<Track> tracks, {int startIndex = 0}) =>
      _handler.playQueue(tracks, startIndex: startIndex);

  Future<void> pause() => _handler.pause();
  Future<void> resume() => _handler.play();
  Future<void> stop() => _handler.stop();
  Future<void> seek(Duration position) => _handler.seek(position);
  Future<void> skipNext() => _handler.skipToNext();
  Future<void> skipPrevious() => _handler.skipToPrevious();

  // ── Queue / volume ────────────────────────────────────────────────────────

  /// Converts our [RepeatMode] → [AudioServiceRepeatMode] so the OS media
  /// controls stay in sync (Linux MPRIS repeat indicator, etc.).
  Future<void> setRepeatMode(RepeatMode mode) => _handler.setRepeatMode(
        switch (mode) {
          RepeatMode.none => AudioServiceRepeatMode.none,
          RepeatMode.one => AudioServiceRepeatMode.one,
          RepeatMode.all => AudioServiceRepeatMode.all,
        },
      );

  Future<void> setShuffleEnabled(bool enabled) => _handler.setShuffleMode(
        enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      );

  Future<void> setVolume(double volume) => _handler.setVolume(volume);
}

// ── Riverpod providers ────────────────────────────────────────────────────────

/// The raw audio handler. Overridden in ProviderScope once AudioService.init()
/// completes in main.dart. Never access this directly from feature code.
final audioHandlerProvider = Provider<DeenAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden at startup');
});

/// The app's audio API. Use this from all feature code and widgets.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService(ref.watch(audioHandlerProvider));
});

/// Current OS-level playback state.
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  return ref.watch(audioPlayerServiceProvider).playbackStateStream;
});

/// Metadata of the currently loaded track.
final currentTrackProvider = StreamProvider<MediaItem?>((ref) {
  return ref.watch(audioPlayerServiceProvider).currentTrackStream;
});

/// Position within the current track.
final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).positionStream;
});

/// Duration of the current track (null until loaded).
final durationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerServiceProvider).durationStream;
});

/// Volume level (0.0–1.0).
final volumeProvider = StreamProvider<double>((ref) {
  return ref.watch(audioPlayerServiceProvider).volumeStream;
});

/// Live queue state: track list, current index, shuffle, repeat.
final queueStateProvider = StreamProvider<QueueState>((ref) {
  return ref.watch(audioPlayerServiceProvider).queueStateStream;
});
