import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'font_size_tile.dart';
import 'library_folder_tile.dart';
import 'location_tile.dart';

/// Settings screen — library folder, prayer location, Quran font size, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Settings'),
          const SizedBox(height: 28),

          // ── Library ─────────────────────────────────────────────────────────
          _section('Library', [const LibraryFolderTile()]),
          const SizedBox(height: 24),

          // ── Prayer ──────────────────────────────────────────────────────────
          _section('Prayer Times', [const LocationTile()]),
          const SizedBox(height: 24),

          // ── Quran ───────────────────────────────────────────────────────────
          _section('Quran', [const FontSizeTile()]),
          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────────────
          _section('About', [
            _infoTile('Version', '0.1.0'),
            _infoTile('Build', 'Phase 5 — Pre-release'),
            _infoTile('Framework', 'Flutter 3 · SQLite (Drift) · Riverpod'),
          ]),
        ],
      ),
    );
  }

  Widget _heading(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 16,
                      endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
