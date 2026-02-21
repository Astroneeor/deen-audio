import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/ayah.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/quran_providers.dart';

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
                ? _EmptyAyahs(surahNumber: selectedNumber)
                : _AyahList(
                    ayahs: ayahs,
                    showTranslation: showTranslation,
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
  final ScrollController controller;
  final void Function(Ayah) onAyahVisible;

  const _AyahList({
    required this.ayahs,
    required this.showTranslation,
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
          return _AyahTile(
            ayah: ayah,
            showTranslation: showTranslation,
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

// ── Ayah tile ─────────────────────────────────────────────────────────────────

class _AyahTile extends StatelessWidget {
  final Ayah ayah;
  final bool showTranslation;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  const _AyahTile({
    required this.ayah,
    required this.showTranslation,
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
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 26,
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

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyAyahs extends StatelessWidget {
  final int surahNumber;
  const _EmptyAyahs({required this.surahNumber});

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
