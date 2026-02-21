import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/adhkar_repository.dart';
import '../../../shared/widgets/shimmer_box.dart';

/// Scrollable list of dhikr cards for a single session (morning or evening).
class AdhkarList extends ConsumerWidget {
  /// Either [morningAdhkarProvider] or [eveningAdhkarProvider].
  final AsyncValue<List<Dhikr>> adhkarAsync;

  const AdhkarList({super.key, required this.adhkarAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return adhkarAsync.when(
      data: (adhkar) => adhkar.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: adhkar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _DhikrCard(dhikr: adhkar[i]),
            ),
      loading: () => const _AdhkarSkeleton(),
      error: (e, _) => Center(
        child: Text('Error loading adhkar: $e',
            style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}

// ── Dhikr card ────────────────────────────────────────────────────────────────

class _DhikrCard extends StatelessWidget {
  final Dhikr dhikr;
  const _DhikrCard({required this.dhikr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  dhikr.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (dhikr.count > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '×${dhikr.count}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Arabic text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              dhikr.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                height: 1.9,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Transliteration
          if (dhikr.transliteration != null) ...[
            const SizedBox(height: 8),
            Text(
              dhikr.transliteration!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Translation
          const SizedBox(height: 6),
          Text(
            dhikr.translation,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),

          // Reference
          if (dhikr.reference != null) ...[
            const SizedBox(height: 10),
            Text(
              dhikr.reference!,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty / skeleton states ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 56, color: AppColors.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No adhkar found',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AdhkarSkeleton extends StatelessWidget {
  const _AdhkarSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _CardSkeleton(),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 160, height: 14),
          SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 26),
          SizedBox(height: 6),
          ShimmerBox(width: double.infinity, height: 14),
          SizedBox(height: 4),
          ShimmerBox(width: 200, height: 14),
        ],
      ),
    );
  }
}
