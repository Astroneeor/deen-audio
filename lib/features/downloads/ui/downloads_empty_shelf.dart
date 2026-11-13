import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shown on a Downloads shelf whose catalog has no packs yet.
class DownloadsEmptyShelf extends StatelessWidget {
  final String? hint;

  const DownloadsEmptyShelf({super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    // Scrolls rather than overflowing when the window is very short.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.gold.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
