import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/byte_formatter.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../data/catalog.dart';
import '../providers/download_providers.dart';
import 'downloads_empty_shelf.dart';
import 'pack_card.dart';

/// Downloads screen: the catalog's packs on two shelves (Reciters, Adhkar)
/// with their progress and actions, and the disk space used in the header.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const TabBar(
            tabs: [
              Tab(text: 'Reciters'),
              Tab(text: 'Adhkar'),
            ],
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.divider,
          ),
          Expanded(
            child: catalog.when(
              data: (c) => TabBarView(
                children: [
                  _Shelf(packs: _ofKind(c, PackKind.quranReciter)),
                  _Shelf(
                    packs: _ofKind(c, PackKind.adhkarScans),
                    emptyHint:
                        'Adhkar scans will appear here once a source is '
                        'available.',
                  ),
                ],
              ),
              loading: () => const _ShelfSkeleton(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load the download catalog: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<CatalogPack> _ofKind(Catalog c, PackKind kind) =>
    c.packs.where((p) => p.kind == kind).toList();

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final used = ref.watch(downloadsUsedBytesProvider).valueOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Downloads',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (used != null)
            Text(
              '${formatBytes(used)} used',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  final List<CatalogPack> packs;
  final String? emptyHint;

  const _Shelf({required this.packs, this.emptyHint});

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) return DownloadsEmptyShelf(hint: emptyHint);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: packs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => PackCard(pack: packs[i]),
    );
  }
}

class _ShelfSkeleton extends StatelessWidget {
  const _ShelfSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) =>
          const ShimmerBox(width: double.infinity, height: 110, borderRadius: 10),
    );
  }
}
