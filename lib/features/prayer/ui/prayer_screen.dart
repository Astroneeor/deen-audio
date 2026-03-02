import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/prayer_providers.dart';
import 'qiblah_compass.dart';

/// Prayer times + Qiblah direction screen.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.watch(prayerTimesProvider);
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

          if (prayerTimes == null)
            _NoLocationCard()
          else
            _PrayerTimesCard(prayerTimes: prayerTimes),

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
          _QiblahCard(direction: qiblahDir),
        ],
      ),
    );
  }
}

// ── No-location banner ────────────────────────────────────────────────────────

class _NoLocationCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_outlined,
              color: AppColors.textMuted, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location not set',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Enter your coordinates in Settings → Prayer Times to see accurate prayer times and Qiblah direction.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
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

// ── Prayer times card ─────────────────────────────────────────────────────────

class _PrayerTimesCard extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const _PrayerTimesCard({required this.prayerTimes});

  @override
  Widget build(BuildContext context) {
    final current = prayerTimes.currentPrayer();
    final next = prayerTimes.nextPrayer();
    final now = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              dateStr,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _PrayerRow(name: 'Fajr', time: prayerTimes.fajr,
              icon: Icons.wb_twilight_outlined,
              isCurrent: current == Prayer.fajr, isNext: next == Prayer.fajr),
          _PrayerRow(name: 'Sunrise', time: prayerTimes.sunrise,
              icon: Icons.wb_sunny_outlined,
              isCurrent: false, isNext: false),
          _PrayerRow(name: 'Dhuhr', time: prayerTimes.dhuhr,
              icon: Icons.wb_sunny,
              isCurrent: current == Prayer.dhuhr, isNext: next == Prayer.dhuhr),
          _PrayerRow(name: 'Asr', time: prayerTimes.asr,
              icon: Icons.filter_drama_outlined,
              isCurrent: current == Prayer.asr, isNext: next == Prayer.asr),
          _PrayerRow(name: 'Maghrib', time: prayerTimes.maghrib,
              icon: Icons.nights_stay_outlined,
              isCurrent: current == Prayer.maghrib,
              isNext: next == Prayer.maghrib),
          _PrayerRow(name: 'Isha', time: prayerTimes.isha,
              icon: Icons.dark_mode_outlined,
              isCurrent: current == Prayer.isha, isNext: next == Prayer.isha,
              isLast: true),
        ],
      ),
    );
  }

  static String _weekday(int d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];
  static String _month(int m) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final DateTime? time;
  final IconData icon;
  final bool isCurrent;
  final bool isNext;
  final bool isLast;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
    required this.isCurrent,
    required this.isNext,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCurrent
        ? AppColors.gold
        : isNext
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    return Container(
      decoration: isCurrent
          ? BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.07),
              border: const Border(
                left: BorderSide(color: AppColors.gold, width: 3),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 14),
          Text(name,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.normal)),
          if (isNext) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Next',
                  style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
          const Spacer(),
          Text(_fmt(time),
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }

  static String _fmt(DateTime? t) {
    if (t == null) return '--:--';
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }
}

// ── Qiblah card ───────────────────────────────────────────────────────────────

class _QiblahCard extends StatelessWidget {
  final double? direction;

  const _QiblahCard({required this.direction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: direction == null
          ? const Center(
              child: Text(
                'Set your location in Settings to see the Qiblah direction.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QiblahCompass(direction: direction!),
                const SizedBox(width: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Direction to Mecca',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        '${direction!.toStringAsFixed(1)}° from North',
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cardinalLabel(direction!),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static String _cardinalLabel(double deg) {
    final dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }
}
