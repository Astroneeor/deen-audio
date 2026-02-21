import 'package:audio_service/audio_service.dart';
// Flutter 3.24+ exports its own RepeatMode from repeating_animation_builder;
// hide it so our queue_manager.dart's RepeatMode is unambiguous.
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player_service.dart';
import '../../../core/audio/queue_manager.dart';
import '../../../core/theme/app_colors.dart';
import 'player_bar_controls.dart';

/// Persistent bottom player bar shown on every screen via [AppScaffold].
class PlayerBar extends ConsumerStatefulWidget {
  const PlayerBar({super.key});

  @override
  ConsumerState<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends ConsumerState<PlayerBar> {
  /// Non-null only while the user is actively dragging the seek slider.
  double? _seekDrag;

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackStateProvider).valueOrNull;
    final track = ref.watch(currentTrackProvider).valueOrNull;
    final position = ref.watch(positionProvider).valueOrNull ?? Duration.zero;
    final duration = ref.watch(durationProvider).valueOrNull ?? Duration.zero;
    final volume = ref.watch(volumeProvider).valueOrNull ?? 1.0;
    final queue = ref.watch(queueStateProvider).valueOrNull ?? const QueueState();

    final isPlaying = playback?.playing ?? false;
    final isLoading = playback?.processingState == AudioProcessingState.loading ||
        playback?.processingState == AudioProcessingState.buffering;
    final hasTrack = track != null;
    final svc = ref.read(audioPlayerServiceProvider);

    // While dragging, show the dragged position; otherwise show stream position.
    final displayPos = _seekDrag != null
        ? Duration(milliseconds: (_seekDrag! * duration.inMilliseconds).round())
        : position;

    return Container(
      color: AppColors.playerBar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // ── Left: track info ─────────────────────────────────────────
                Expanded(flex: 3, child: _TrackInfo(track: track)),

                // ── Centre: controls + seek ───────────────────────────────────
                Expanded(
                  flex: 5,
                  child: PlayerBarControls(
                    isPlaying: isPlaying,
                    isLoading: isLoading,
                    hasTrack: hasTrack,
                    position: displayPos,
                    duration: duration,
                    seekValue: _seekDrag,
                    onPlayPause: hasTrack
                        ? () => isPlaying ? svc.pause() : svc.resume()
                        : null,
                    onSkipPrev: hasTrack ? svc.skipPrevious : null,
                    onSkipNext: hasTrack ? svc.skipNext : null,
                    onSeekChanged: (v) => setState(() => _seekDrag = v),
                    onSeekEnd: (v) {
                      setState(() => _seekDrag = null);
                      svc.seek(Duration(
                        milliseconds: (v * duration.inMilliseconds).round(),
                      ));
                    },
                  ),
                ),

                // ── Right: shuffle / repeat / volume ──────────────────────────
                Expanded(
                  flex: 3,
                  child: PlayerBarExtras(
                    volume: volume,
                    shuffleEnabled: queue.shuffleEnabled,
                    repeatMode: queue.repeatMode,
                    onVolumeChanged: svc.setVolume,
                    onShuffleTap: () =>
                        svc.setShuffleEnabled(!queue.shuffleEnabled),
                    onRepeatTap: () {
                      final next = RepeatMode.values[
                          (queue.repeatMode.index + 1) %
                              RepeatMode.values.length];
                      svc.setRepeatMode(next);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Left panel: album art + track title/artist ────────────────────────────────

class _TrackInfo extends StatelessWidget {
  final MediaItem? track;
  const _TrackInfo({this.track});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.music_note,
              color: AppColors.textMuted, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track?.title ?? 'No track playing',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (track?.artist != null)
                Text(
                  track!.artist!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
