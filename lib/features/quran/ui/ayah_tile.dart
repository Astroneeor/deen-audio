import 'package:flutter/material.dart';

import '../../../core/models/ayah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

/// A single ayah row: number badge, bookmark toggle, Arabic text, translation.
class AyahTile extends StatelessWidget {
  final Ayah ayah;
  final bool showTranslation;
  final double fontSize;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  const AyahTile({
    super.key,
    required this.ayah,
    required this.showTranslation,
    required this.fontSize,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ayah number + bookmark row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AyahBadge(number: ayah.ayahNumber),
            IconButton(
              onPressed: onBookmarkTap,
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              color: isBookmarked ? AppColors.gold : AppColors.textMuted,
              iconSize: 16,
              splashRadius: 14,
              tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark ayah',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Arabic text (right-to-left)
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            ayah.arabicText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppFonts.quranText,
              fontSize: fontSize,
              height: 1.9,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // English translation
        if (showTranslation && ayah.translation != null) ...[
          const SizedBox(height: 10),
          Text(
            ayah.translation!,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _AyahBadge extends StatelessWidget {
  final int number;
  const _AyahBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

/// Shown when a surah's ayahs are not in the current JSON stub.
class EmptyAyahsView extends StatelessWidget {
  const EmptyAyahsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 56, color: AppColors.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text(
            'Ayahs not in stub dataset',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Download the full quran_simple.json from tanzil.net\n'
            'and replace assets/quran/quran_simple.json',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
