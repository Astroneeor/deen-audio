import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/library_providers.dart';
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
                ? _EmptyState(isScanning: scanState.isLoading)
                : _TrackList(tracks: tracks),
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2),
            ),
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

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final AsyncValue<String?> scanState;

  const _Header({required this.scanState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = scanState.isLoading;
    final folderName = scanState.valueOrNull?.split('/').last ??
        scanState.valueOrNull?.split(r'\').last;

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
                if (folderName != null)
                  Text(
                    folderName,
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
      onPressed: () => ref.read(scanNotifierProvider.notifier).pickAndScan(),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends ConsumerWidget {
  final bool isScanning;

  const _EmptyState({required this.isScanning});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isScanning) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            SizedBox(height: 20),
            Text('Scanning…',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 64, color: AppColors.gold.withValues(alpha: 0.35)),
          const SizedBox(height: 20),
          const Text(
            'Your library is empty',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Put your audio files in ~/HalalAudio/\nthen tap Scan Folder to import them.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(scanNotifierProvider.notifier).pickAndScan(),
            icon: const Icon(Icons.folder_open_outlined, size: 18),
            label: const Text('Scan Folder'),
          ),
        ],
      ),
    );
  }
}
