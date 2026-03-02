import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../providers/settings_providers.dart';

/// Settings tile: Quran font size slider with live Arabic preview.
class FontSizeTile extends ConsumerWidget {
  const FontSizeTile({super.key});

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
          // Live preview
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: TextStyle(
                fontFamily: AppFonts.quranText,
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
