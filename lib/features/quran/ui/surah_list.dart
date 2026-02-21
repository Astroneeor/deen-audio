import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../providers/quran_providers.dart';

/// Left panel: scrollable list of all 114 surahs.
/// Tap to select a surah and update [selectedSurahNumberProvider].
class SurahList extends ConsumerWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);
    final selectedNumber = ref.watch(selectedSurahNumberProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Surahs',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),

        // List
        Expanded(
          child: surahsAsync.when(
            data: (surahs) => ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: surahs.length,
              itemBuilder: (_, i) {
                final s = surahs[i];
                final isSelected = s.number == selectedNumber;
                return _SurahTile(
                  number: s.number,
                  arabicName: s.name,
                  englishName: s.englishName,
                  ayahCount: s.numberOfAyahs,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedSurahNumberProvider.notifier).state =
                        s.number;
                  },
                );
              },
            ),
            loading: () => const _SurahListSkeleton(),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.error)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _SurahListSkeleton extends StatelessWidget {
  const _SurahListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 12,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            ShimmerBox(width: 28, height: 12),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(width: 90, height: 14),
                  SizedBox(height: 5),
                  ShimmerBox(width: 120, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Surah tile ─────────────────────────────────────────────────────────────────

class _SurahTile extends StatelessWidget {
  final int number;
  final String arabicName;
  final String englishName;
  final int ayahCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _SurahTile({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.ayahCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.gold.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: isSelected
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.gold, width: 3),
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Number badge
              SizedBox(
                width: 28,
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.gold : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      arabicName,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.textPrimary,
                        // Download Amiri-Regular.ttf to assets/fonts/ and
                        // declare it in pubspec.yaml to enable Amiri font.
                        fontFamily: 'Amiri',
                      ),
                    ),
                    Text(
                      '$englishName · $ayahCount ayahs',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
