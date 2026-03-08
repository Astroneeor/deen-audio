import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player_service.dart';
import '../../../core/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/shimmer_box.dart';
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
    final filter = ref.watch(trackTypeFilterProvider);

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
                : filter == TrackType.quran
                    ? _QuranGroupedList(tracks: tracks)
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

// ── Quran grouped view ────────────────────────────────────────────────────────

/// Groups Quran tracks by surah number, then shows available reciters as
/// expandable sub-items.  Per-ayah files are excluded from the top level
/// (they play automatically from the Quran reader).
class _QuranGroupedList extends StatelessWidget {
  final List<Track> tracks;

  const _QuranGroupedList({required this.tracks});

  @override
  Widget build(BuildContext context) {
    // Only full-surah files drive the grouping; ayah files surface via reciter.
    final surahTracks = tracks.where((t) => !t.isAyahFile).toList();

    // Build: surahNumber → artist → tracks
    final groups = <String, Map<String, List<Track>>>{};
    for (final track in surahTracks) {
      final surah = track.surahNumber ?? '???';
      final artist = track.artist ?? 'Unknown';
      groups.putIfAbsent(surah, () => {})[artist] ??= [];
      groups[surah]![artist]!.add(track);
    }

    if (groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No Quran audio found.\n\nPut surah MP3s in ~/HalalAudio/Quran/<ReciterName>/ and rescan.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedSurahs = groups.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedSurahs.length,
      itemBuilder: (_, i) => _SurahGroup(
        surahNumber: sortedSurahs[i],
        reciters: groups[sortedSurahs[i]]!,
      ),
    );
  }
}

class _SurahGroup extends ConsumerWidget {
  final String surahNumber;
  final Map<String, List<Track>> reciters;

  const _SurahGroup({required this.surahNumber, required this.reciters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      // Remove the default ExpansionTile dividers
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            // Show numeric surah number without leading zeros
            '${int.tryParse(surahNumber) ?? surahNumber}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ),
        title: Text(
          'Surah $surahNumber',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${reciters.length} ${reciters.length == 1 ? 'reciter' : 'reciters'}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        iconColor: AppColors.textMuted,
        collapsedIconColor: AppColors.textMuted,
        children: reciters.entries.map((entry) {
          final artist = entry.key;
          final reciterTracks = entry.value;
          return ListTile(
            contentPadding:
                const EdgeInsets.only(left: 72, right: 16),
            title: Text(
              artist,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              '${reciterTracks.length} file${reciterTracks.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            trailing: const Icon(
              Icons.play_circle_outline,
              color: AppColors.gold,
              size: 20,
            ),
            onTap: () => ref
                .read(audioPlayerServiceProvider)
                .playQueue(reciterTracks)
                .catchError(
                    (Object e) => debugPrint('[QuranGroup] play error: $e')),
          );
        }).toList(),
      ),
    );
  }
}
