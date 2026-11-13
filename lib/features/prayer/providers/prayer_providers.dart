import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_providers.dart';
import '../data/prayer_schedule.dart';

/// Source of the current time. Overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's prayer times with the current / next prayer, for the stored
/// location. Times are in this computer's time zone.
///
/// Null when no location has been set, or when the times cannot be
/// calculated there (polar day / night).
///
/// Keeps itself up to date: it re-evaluates when the next prayer begins and
/// at midnight, and at least once a minute so it also recovers after the
/// computer sleeps or its clock / time zone changes. Listeners are only
/// notified when the schedule actually differs.
final prayerScheduleProvider = Provider<PrayerSchedule?>((ref) {
  final loc = ref.watch(locationSettingsProvider);
  if (!loc.hasLocation) return null;

  final now = ref.watch(clockProvider)();
  final coords = Coordinates(loc.latitude!, loc.longitude!);
  final params = _calcParams(loc.calculationMethod);

  PrayerSchedule? schedule;
  try {
    schedule = PrayerSchedule.at(
      now,
      (day) => DayPrayerTimes.calculate(coords, params, day),
    );
  } on ArgumentError {
    schedule = null; // adhan has no result for this latitude / date
  }

  var wait = _maxRefreshInterval;
  if (schedule != null) {
    final untilChange = schedule.validUntil.difference(now);
    if (untilChange < wait) wait = untilChange;
    if (wait < _minRefreshInterval) wait = _minRefreshInterval;
  }
  final timer = Timer(wait, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return schedule;
});

const _maxRefreshInterval = Duration(minutes: 1);
const _minRefreshInterval = Duration(seconds: 1);

/// Qibla bearing in degrees clockwise from true North.
/// Returns null when no location has been set.
final qiblahDirectionProvider = Provider<double?>((ref) {
  final loc = ref.watch(locationSettingsProvider);
  if (!loc.hasLocation) return null;

  final coords = Coordinates(loc.latitude!, loc.longitude!);
  return Qibla(coords).direction;
});

/// Maps a persisted method id (see [prayerCalculationMethods]) to adhan.
CalculationParameters _calcParams(String method) {
  switch (method) {
    case 'northAmerica':
      return CalculationMethod.north_america.getParameters();
    case 'egyptian':
      return CalculationMethod.egyptian.getParameters();
    case 'karachi':
      return CalculationMethod.karachi.getParameters();
    case 'ummAlQura':
      return CalculationMethod.umm_al_qura.getParameters();
    case 'kuwait':
      return CalculationMethod.kuwait.getParameters();
    case 'qatar':
      return CalculationMethod.qatar.getParameters();
    case 'singapore':
      return CalculationMethod.singapore.getParameters();
    case 'turkey':
      return CalculationMethod.turkey.getParameters();
    case 'muslimWorldLeague':
    default:
      return CalculationMethod.muslim_world_league.getParameters();
  }
}
