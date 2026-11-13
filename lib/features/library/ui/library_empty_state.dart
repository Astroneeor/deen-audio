import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/library_providers.dart';

/// Shown in place of the track list when there is nothing to list:
/// a scan in progress, a filter with no matches, or an empty library.
class LibraryEmptyState extends ConsumerWidget {
  final bool isScanning;

  /// The active type filter when the library itself is not empty but has no
  /// tracks of that type; null otherwise.
  final TrackType? emptyFilter;

  const LibraryEmptyState({
    super.key,
    required this.isScanning,
    this.emptyFilter,
  });

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

    if (emptyFilter != null) {
      return Center(
        child: Text(
          'No ${emptyFilter!.label} tracks in your library',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Scrolls rather than overflowing when the window is very short.
    return Center(
      child: SingleChildScrollView(
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
      ),
    );
  }
}
