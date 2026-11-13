import 'package:adhan/adhan.dart' show Prayer;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/prayer_schedule.dart';

/// Today's prayer times with the current prayer highlighted and the next
/// one badged. Purely presentational: everything comes from [schedule].
class PrayerTimesCard extends StatelessWidget {
  final PrayerSchedule schedule;

  const PrayerTimesCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final date = schedule.date;
    final dateStr = '${_weekday(date.weekday)}, ${date.day} '
        '${_month(date.month)} ${date.year}';

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
              "$dateStr · shown in this computer's time zone",
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _row(Prayer.fajr, 'Fajr', Icons.wb_twilight_outlined),
          _row(Prayer.sunrise, 'Sunrise', Icons.wb_sunny_outlined),
          _row(Prayer.dhuhr, 'Dhuhr', Icons.wb_sunny),
          _row(Prayer.asr, 'Asr', Icons.filter_drama_outlined),
          _row(Prayer.maghrib, 'Maghrib', Icons.nights_stay_outlined),
          _row(Prayer.isha, 'Isha', Icons.dark_mode_outlined),
        ],
      ),
    );
  }

  Widget _row(Prayer prayer, String name, IconData icon) {
    final isNext = schedule.next == prayer;
    final nextDay = isNext && schedule.nextIsOnAnotherDay;
    return _PrayerRow(
      name: name,
      // After Isha the upcoming Fajr is tomorrow's, so show that time.
      time: nextDay ? schedule.nextTime : schedule.today.timeOf(prayer),
      icon: icon,
      isCurrent: schedule.current == prayer,
      isNext: isNext,
      nextLabel: nextDay && schedule.nextTime.isAfter(_endOf(schedule.date))
          ? 'Next · tomorrow'
          : 'Next',
    );
  }

  static DateTime _endOf(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1);

  static String _weekday(int d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];
  static String _month(int m) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final DateTime time;
  final IconData icon;
  final bool isCurrent;
  final bool isNext;
  final String nextLabel;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
    required this.isCurrent,
    required this.isNext,
    this.nextLabel = 'Next',
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
          const SizedBox(width: 6),
          Expanded(
            child: isNext
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(nextLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 6),
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

  static String _fmt(DateTime t) {
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }
}
