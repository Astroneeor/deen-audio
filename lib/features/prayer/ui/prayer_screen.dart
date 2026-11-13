import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/prayer_providers.dart';
import 'prayer_times_card.dart';
import 'qiblah_card.dart';

/// Prayer times + Qiblah direction screen.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLocation = ref.watch(
        locationSettingsProvider.select((loc) => loc.hasLocation));
    final schedule = ref.watch(prayerScheduleProvider);
    final qiblahDir = ref.watch(qiblahDirectionProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prayer Times',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          if (!hasLocation)
            const _NoticeCard(
              icon: Icons.location_off_outlined,
              title: 'Location not set',
              message: 'Enter your coordinates in Settings → Prayer Times '
                  'to see accurate prayer times and Qiblah direction.',
              showSettingsButton: true,
            )
          else if (schedule == null)
            const _NoticeCard(
              icon: Icons.error_outline,
              title: 'Prayer times unavailable here',
              message: 'Times cannot be calculated for the saved '
                  'coordinates on this date (for example inside the polar '
                  'circles, where the sun may not rise or set). Check the '
                  'coordinates in Settings.',
              showSettingsButton: true,
            )
          else
            PrayerTimesCard(schedule: schedule),

          const SizedBox(height: 28),

          const Text(
            'Qiblah',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          QiblahCard(direction: qiblahDir),
        ],
      ),
    );
  }
}

// ── Notice card (no location / not computable) ───────────────────────────────

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool showSettingsButton;

  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
    this.showSettingsButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (showSettingsButton)
            TextButton(
              onPressed: () => context.go(AppRoutes.settings),
              style: TextButton.styleFrom(foregroundColor: AppColors.gold),
              child: const Text('Settings'),
            ),
        ],
      ),
    );
  }
}
