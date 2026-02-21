import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/library/providers/library_providers.dart';
import '../providers/settings_providers.dart';

/// Settings screen — library folder, Quran font size, and app info.
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
          _section('Library', [
            _LibraryFolderTile(),
          ]),
          const SizedBox(height: 24),

          // ── Quran ───────────────────────────────────────────────────────────
          _section('Quran', [
            _FontSizeTile(),
          ]),
          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────────────
          _section('About', [
            _infoTile('Version', '0.1.0'),
            _infoTile('Build', 'Phase 5 — Pre-release'),
            _infoTile('Framework', 'Flutter 3 · Isar · Riverpod'),
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
                  const Divider(height: 1, color: AppColors.divider,
                      indent: 16, endIndent: 16),
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
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Library folder tile ───────────────────────────────────────────────────────

class _LibraryFolderTile extends ConsumerWidget {
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
                  folder != null
                      ? folder.split('/').last
                      : 'No folder selected',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: scanState.isLoading
                ? null
                : () => ref
                    .read(scanNotifierProvider.notifier)
                    .pickAndScan(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            child: Text(folder != null ? 'Rescan' : 'Choose folder'),
          ),
        ],
      ),
    );
  }
}

// ── Font size tile ────────────────────────────────────────────────────────────

class _FontSizeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(quranFontSizeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields_outlined,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 12),
              const Text('Quran font size',
                  style:
                      TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              const Spacer(),
              Text(
                '${fontSize.round()}px',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: fontSize,
            min: 18,
            max: 48,
            divisions: 30,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.surfaceVariant,
            onChanged: (v) =>
                ref.read(quranFontSizeProvider.notifier).set(v),
          ),
          // Preview
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: fontSize,
                color: AppColors.textPrimary.withValues(alpha: 0.6),
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
