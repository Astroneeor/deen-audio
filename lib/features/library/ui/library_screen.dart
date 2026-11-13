import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../providers/library_providers.dart';
import 'library_empty_state.dart';
import 'library_filter_bar.dart';
import 'track_list_tile.dart';

/// Main library screen — filter tabs, scrollable track list, scan button.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTracksProvider);
    final scanState = ref.watch(scanNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(scanState: scanState),
        const LibraryFilterBar(),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: filteredAsync.when(
            data: (tracks) => tracks.isEmpty
                ? LibraryEmptyState(
                    isScanning: scanState.isLoading,
                    // Non-null when the library has tracks, just none of
                    // the selected type.
                    emptyFilter: _libraryHasTracks(ref)
                        ? ref.watch(trackTypeFilterProvider)
                        : null,
                  )
                : _TrackList(tracks: tracks),
            loading: () => const _TrackListSkeleton(),
            error: (e, _) => Center(
              child: Text('Error loading library: $e',
                  style: const TextStyle(color: AppColors.error)),
            ),
          ),
        ),
      ],
    );
  }
}

bool _libraryHasTracks(WidgetRef ref) =>
    ref.watch(tracksStreamProvider).valueOrNull?.isNotEmpty ?? false;

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final AsyncValue<String?> scanState;

  const _Header({required this.scanState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = scanState.isLoading;
    final folder = scanState.valueOrNull;
    final folderName = folder == null ? null : p.basename(folder);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Library',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (scanState.hasError)
                  Text(
                    'Scan failed: ${scanState.error}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 11),
                  )
                else if (folderName != null)
                  Text(
                    folderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.gold),
              ),
            )
          else
            _ScanButton(),
        ],
      ),
    );
  }
}

class _ScanButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFolder =
        ref.watch(scanNotifierProvider).valueOrNull != null;

    return TextButton.icon(
      // Re-reads the folder (or asks for one); Settings changes the folder.
      onPressed: () => ref.read(scanNotifierProvider.notifier).rescan(),
      icon: Icon(hasFolder ? Icons.refresh : Icons.folder_open_outlined,
          size: 16),
      label: Text(hasFolder ? 'Rescan' : 'Scan Folder'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        textStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Track list ────────────────────────────────────────────────────────────────

class _TrackList extends StatelessWidget {
  final List<Track> tracks;

  const _TrackList({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tracks.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider, indent: 72),
      itemBuilder: (_, i) => TrackListTile(
        track: tracks[i],
        queue: tracks,
        index: i,
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _TrackListSkeleton extends StatelessWidget {
  const _TrackListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider, indent: 72),
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            ShimmerBox(width: 38, height: 38, borderRadius: 6),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(width: double.infinity, height: 13),
                  SizedBox(height: 6),
                  ShimmerBox(width: 120, height: 11),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerBox(width: 36, height: 12),
          ],
        ),
      ),
    );
  }
}
