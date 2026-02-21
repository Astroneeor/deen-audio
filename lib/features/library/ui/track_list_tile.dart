import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player_service.dart';
import '../../../core/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/duration_formatter.dart';
import '../providers/library_providers.dart';

/// A single row in the track list.
///
/// [queue]  — the full filtered list, so tapping plays the surrounding context.
/// [index]  — position of [track] within [queue].
class TrackListTile extends ConsumerWidget {
  final Track track;
  final List<Track> queue;
  final int index;

  const TrackListTile({
    super.key,
    required this.track,
    required this.queue,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(currentTrackProvider).valueOrNull;
    // MediaItem.id is set to filePath in DeenAudioHandler._toMediaItem()
    final isActive = currentItem?.id == track.filePath;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref
            .read(audioPlayerServiceProvider)
            .playQueue(queue, startIndex: index),
        onLongPress: () => _showContextMenu(context, ref),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // ── Type icon ──────────────────────────────────────────────────
              _TypeIcon(type: track.type, isActive: isActive),
              const SizedBox(width: 14),

              // ── Title + artist ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive
                            ? AppColors.gold
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (track.artist != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        track.artist!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Duration ───────────────────────────────────────────────────
              if (track.duration > 0) ...[
                const SizedBox(width: 12),
                Text(
                  formatDuration(Duration(milliseconds: track.duration)),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],

              // ── Favourite button ───────────────────────────────────────────
              const SizedBox(width: 4),
              IconButton(
                onPressed: () =>
                    ref.read(libraryRepositoryProvider).toggleFavorite(track),
                icon: Icon(
                  track.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: track.isFavorite ? AppColors.gold : AppColors.textMuted,
                iconSize: 18,
                splashRadius: 16,
                tooltip: track.isFavorite ? 'Remove favourite' : 'Add favourite',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _TrackContextMenu(track: track, ref: ref),
    );
  }
}

// ── Type icon ─────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  final TrackType type;
  final bool isActive;

  const _TypeIcon({required this.type, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.15)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        type.icon,
        size: 18,
        color: isActive ? AppColors.gold : AppColors.textSecondary,
      ),
    );
  }
}

// ── Context menu (long-press) ─────────────────────────────────────────────────

class _TrackContextMenu extends StatelessWidget {
  final Track track;
  final WidgetRef ref;

  const _TrackContextMenu({required this.track, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              track.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          ListTile(
            leading: Icon(
              track.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: track.isFavorite ? AppColors.gold : AppColors.textSecondary,
            ),
            title: Text(
              track.isFavorite ? 'Remove from favourites' : 'Add to favourites',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              ref.read(libraryRepositoryProvider).toggleFavorite(track);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline,
                color: AppColors.textSecondary),
            title: const Text('Play next',
                style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              // Phase 5: add to queue at next position
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
