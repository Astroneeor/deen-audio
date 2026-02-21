import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _PlaceholderContent(
        icon: Icons.library_music_outlined,
        title: 'Library',
        subtitle: 'Phase 2 — Local folder scanner coming soon',
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: AppColors.gold.withValues(alpha: 0.4)),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
