// ignore_for_file: avoid_positional_boolean_parameters
import 'package:flutter/material.dart' hide RepeatMode;

import '../../../core/audio/queue_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/duration_formatter.dart';

/// Centre panel: skip prev/next, play-pause, seek slider + time display.
class PlayerBarControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final bool hasTrack;
  final Duration position;
  final Duration duration;
  final double? seekValue;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSkipPrev;
  final VoidCallback? onSkipNext;
  final ValueChanged<double> onSeekChanged;
  final ValueChanged<double> onSeekEnd;

  const PlayerBarControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.hasTrack,
    required this.position,
    required this.duration,
    required this.seekValue,
    required this.onPlayPause,
    required this.onSkipPrev,
    required this.onSkipNext,
    required this.onSeekChanged,
    required this.onSeekEnd,
  });

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds.toDouble();
    final posMs =
        position.inMilliseconds.toDouble().clamp(0.0, maxMs > 0 ? maxMs : 1.0);
    final sliderValue = maxMs > 0 ? (seekValue ?? posMs / maxMs) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Buttons ───────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onSkipPrev,
              icon: const Icon(Icons.skip_previous_rounded),
              color: onSkipPrev != null
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              iconSize: 22,
              splashRadius: 18,
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onPlayPause,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: hasTrack ? AppColors.gold : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: hasTrack
                            ? AppColors.background
                            : AppColors.textMuted,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onSkipNext,
              icon: const Icon(Icons.skip_next_rounded),
              color: onSkipNext != null
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              iconSize: 22,
              splashRadius: 18,
            ),
          ],
        ),
        // ── Seek row ──────────────────────────────────────────────────────
        Row(
          children: [
            Text(formatDuration(position),
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: sliderValue.clamp(0.0, 1.0),
                  onChanged: hasTrack ? onSeekChanged : null,
                  onChangeEnd: hasTrack ? onSeekEnd : null,
                ),
              ),
            ),
            Text(formatDuration(duration),
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

// ── Right panel: shuffle, repeat, volume ─────────────────────────────────────

/// Right panel: shuffle toggle, repeat cycle, volume slider.
class PlayerBarExtras extends StatelessWidget {
  final double volume;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onShuffleTap;
  final VoidCallback onRepeatTap;

  const PlayerBarExtras({
    super.key,
    required this.volume,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.onVolumeChanged,
    required this.onShuffleTap,
    required this.onRepeatTap,
  });

  @override
  Widget build(BuildContext context) {
    final repeatIcon = switch (repeatMode) {
      RepeatMode.none => Icons.repeat_rounded,
      RepeatMode.one => Icons.repeat_one_rounded,
      RepeatMode.all => Icons.repeat_rounded,
    };
    final repeatActive = repeatMode != RepeatMode.none;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onShuffleTap,
          icon: const Icon(Icons.shuffle_rounded),
          color: shuffleEnabled ? AppColors.gold : AppColors.textMuted,
          iconSize: 18,
          splashRadius: 16,
          tooltip: 'Shuffle',
        ),
        IconButton(
          onPressed: onRepeatTap,
          icon: Icon(repeatIcon),
          color: repeatActive ? AppColors.gold : AppColors.textMuted,
          iconSize: 18,
          splashRadius: 16,
          tooltip: switch (repeatMode) {
            RepeatMode.none => 'Repeat off',
            RepeatMode.one => 'Repeat one',
            RepeatMode.all => 'Repeat all',
          },
        ),
        const Icon(Icons.volume_up_rounded,
            color: AppColors.textMuted, size: 16),
        SizedBox(
          width: 80,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            ),
            child: Slider(
              value: volume.clamp(0.0, 1.0),
              onChanged: onVolumeChanged,
            ),
          ),
        ),
      ],
    );
  }
}
