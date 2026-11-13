import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/theme/app_colors.dart';
import '../../library/providers/library_providers.dart';

/// Settings tile: shows the current library folder and lets the user pick a
/// different one (which is then scanned). Re-reading the same folder is the
/// Library screen's "Rescan" button.
class LibraryFolderTile extends ConsumerWidget {
  const LibraryFolderTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanNotifierProvider);
    final folder = scanState.valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined,
              color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Library folder',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
                Text(
                  folder != null ? p.basename(folder) : 'No folder selected',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (scanState.hasError)
                  Text(
                    'Scan failed: ${scanState.error}',
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: scanState.isLoading
                ? null
                : () =>
                    ref.read(scanNotifierProvider.notifier).pickAndScan(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
            child: Text(folder != null ? 'Change folder' : 'Choose folder'),
          ),
        ],
      ),
    );
  }
}
