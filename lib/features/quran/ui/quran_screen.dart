import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/quran_providers.dart';
import 'ayah_reader.dart';
import 'surah_list.dart';

/// Quran reader screen — two-panel desktop layout.
///
/// ┌─────────────────────┬────────────────────────────────────┐
/// │  SurahList (260px)  │         AyahReader (expanded)      │
/// └─────────────────────┴────────────────────────────────────┘
///
/// On launch the last-read surah is restored automatically.
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Restore last-read surah on first load.
    ref.listen(lastReadProvider, (_, next) {
      next.whenData((pos) {
        final current = ref.read(selectedSurahNumberProvider);
        if (current == 1) {
          // Only restore if user hasn't already navigated away from default.
          ref.read(selectedSurahNumberProvider.notifier).state = pos.surah;
        }
      });
    });

    return Row(
      children: [
        // Left: surah navigator
        SizedBox(
          width: 260,
          child: Container(
            color: AppColors.sidebar,
            child: const SurahList(),
          ),
        ),

        const VerticalDivider(width: 1, color: AppColors.divider),

        // Right: ayah reader
        const Expanded(child: AyahReader()),
      ],
    );
  }
}
