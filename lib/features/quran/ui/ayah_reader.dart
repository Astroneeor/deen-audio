import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/ayah.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/settings/providers/settings_providers.dart';
import '../providers/quran_providers.dart';
import 'ayah_tile.dart';

/// Right panel: displays all ayahs for the selected surah.
///
/// Features:
/// - Arabic text (RTL, large, Amiri font)
/// - Optional English translation
/// - Tap ayah → toggle bookmark
/// - Saves last-read position on scroll
class AyahReader extends ConsumerStatefulWidget {
  const AyahReader({super.key});

  @override
  ConsumerState<AyahReader> createState() => _AyahReaderState();
}

class _AyahReaderState extends ConsumerState<AyahReader> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);
    final ayahsAsync = ref.watch(currentAyahsProvider);
    final selectedNumber = ref.watch(selectedSurahNumberProvider);
    final showTranslation = ref.watch(showTranslationProvider);
    final fontSize = ref.watch(quranFontSizeProvider);

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _Header(
          surahsAsync: surahsAsync,
          selectedNumber: selectedNumber,
          showTranslation: showTranslation,
        ),
        const Divider(height: 1, color: AppColors.divider),

        // ── Ayah list ────────────────────────────────────────────────────────
        Expanded(
          child: ayahsAsync.when(
            data: (ayahs) => ayahs.isEmpty
                ? const EmptyAyahsView()
                : _AyahList(
                    ayahs: ayahs,
                    showTranslation: showTranslation,
                    fontSize: fontSize,
                    controller: _controller,
                    onAyahVisible: (ayah) {
                      ref
                          .read(quranRepositoryProvider)
                          .saveLastRead(ayah.surahNumber, ayah.ayahNumber);
                    },
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2),
            ),
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

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final AsyncValue<List<Surah>> surahsAsync;
  final int selectedNumber;
  final bool showTranslation;

  const _Header({
    required this.surahsAsync,
    required this.selectedNumber,
    required this.showTranslation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surah = surahsAsync.valueOrNull
        ?.where((s) => s.number == selectedNumber)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (surah != null) ...[
                  Text(
                    surah.name,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    '${surah.englishName} · ${surah.englishNameTranslation} · '
                    '${surah.numberOfAyahs} ayahs · ${surah.revelationType}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ] else
                  const Text(
                    'Select a surah',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
              ],
            ),
          ),
          // Translation toggle
          Tooltip(
            message: showTranslation ? 'Hide translation' : 'Show translation',
            child: IconButton(
              onPressed: () => ref
                  .read(showTranslationProvider.notifier)
                  .state = !showTranslation,
              icon: Icon(
                showTranslation
                    ? Icons.translate
                    : Icons.translate_outlined,
              ),
              color: showTranslation ? AppColors.gold : AppColors.textMuted,
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ayah list ─────────────────────────────────────────────────────────────────

class _AyahList extends ConsumerWidget {
  final List<Ayah> ayahs;
  final bool showTranslation;
  final double fontSize;
  final ScrollController controller;
  final void Function(Ayah) onAyahVisible;

  const _AyahList({
    required this.ayahs,
    required this.showTranslation,
    required this.fontSize,
    required this.controller,
    required this.onAyahVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAsync = ref.watch(bookmarkedAyahsProvider);
    final bookmarked = bookmarkedAsync.valueOrNull ?? {};

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollUpdateNotification && ayahs.isNotEmpty) {
          // Approximate visible ayah from scroll ratio
          final ratio = (controller.offset /
                  (controller.position.maxScrollExtent + 1))
              .clamp(0.0, 1.0);
          final idx = (ratio * (ayahs.length - 1)).round();
          onAyahVisible(ayahs[idx]);
        }
        return false;
      },
      child: ListView.separated(
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        itemCount: ayahs.length,
        separatorBuilder: (_, __) => const Divider(
          height: 32,
          color: AppColors.divider,
        ),
        itemBuilder: (_, i) {
          final ayah = ayahs[i];
          return AyahTile(
            ayah: ayah,
            showTranslation: showTranslation,
            fontSize: fontSize,
            isBookmarked: bookmarked.contains(ayah.ayahNumber),
            onBookmarkTap: () => ref
                .read(quranRepositoryProvider)
                .toggleBookmark(ayah.surahNumber, ayah.ayahNumber),
          );
        },
      ),
    );
  }
}

