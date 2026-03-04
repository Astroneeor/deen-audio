import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../data/adhkar_repository.dart';
import '../providers/adhkar_providers.dart';
import 'adhkar_list.dart';
import 'tasbih_counter.dart';

/// Adhkar screen — Morning / Evening / Browse tabs with dhikr cards and tasbih.
class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final morningAsync = ref.watch(morningAdhkarProvider);
    final eveningAsync = ref.watch(eveningAdhkarProvider);
    final categoriesAsync = ref.watch(azkarCategoriesProvider);

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Adhkar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Open Tasbih Counter',
                  child: IconButton(
                    icon: const Icon(Icons.radio_button_unchecked_outlined),
                    color: AppColors.gold,
                    iconSize: 22,
                    onPressed: () => showTasbihCounter(context),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab bar ─────────────────────────────────────────────────────────
          const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: 'Morning'),
              Tab(text: 'Evening'),
              Tab(text: 'Browse'),
            ],
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.divider,
          ),

          // ── Content ─────────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                AdhkarList(adhkarAsync: morningAsync),
                AdhkarList(adhkarAsync: eveningAsync),
                _AzkarBrowser(categoriesAsync: categoriesAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Browse all azkar categories from azkar-db.
class _AzkarBrowser extends StatelessWidget {
  final AsyncValue<List<AzkarCategory>> categoriesAsync;

  const _AzkarBrowser({required this.categoriesAsync});

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (categories) => categories.isEmpty
          ? const Center(
              child: Text('No categories found',
                  style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              itemBuilder: (_, i) =>
                  _CategoryTile(category: categories[i]),
            ),
      loading: () => const Center(
        child:
            CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}

/// Expandable tile for a single azkar category.
class _CategoryTile extends StatelessWidget {
  final AzkarCategory category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: AppColors.gold,
        collapsedIconColor: AppColors.textMuted,
        title: Text(
          category.name,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: AppFonts.quranText,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${category.entries.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
        children: category.entries
            .map((entry) => _AzkarEntryCard(entry: entry))
            .toList(),
      ),
    );
  }
}

/// A single azkar entry card inside the expanded category.
class _AzkarEntryCard extends StatelessWidget {
  final AzkarEntry entry;

  const _AzkarEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Count + reference row
          if (entry.count > 1 || entry.reference != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (entry.count > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '×${entry.count}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (entry.reference != null)
                    Flexible(
                      child: Text(
                        entry.reference!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

          // Arabic text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              entry.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppFonts.quranText,
                fontSize: 18,
                height: 1.9,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Description (Arabic hadith note)
          if (entry.description != null &&
              entry.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                entry.description!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
