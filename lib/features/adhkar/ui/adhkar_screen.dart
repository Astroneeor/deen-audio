import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/adhkar_providers.dart';
import 'adhkar_list.dart';
import 'tasbih_counter.dart';

/// Adhkar screen — Morning / Evening tabs with dhikr cards and tasbih counter.
class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final morningAsync = ref.watch(morningAdhkarProvider);
    final eveningAsync = ref.watch(eveningAdhkarProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
