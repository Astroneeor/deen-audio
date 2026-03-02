import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_providers.dart';

/// Today's prayer times calculated from the stored location.
/// Returns null when no location has been set.
final prayerTimesProvider = Provider<PrayerTimes?>((ref) {
  final loc = ref.watch(locationSettingsProvider);
  if (!loc.hasLocation) return null;

  final coords = Coordinates(loc.latitude!, loc.longitude!);
  final params = _calcParams(loc.calculationMethod);
  final utcOffset = UtcOffset(DateTime.now().timeZoneOffset);

  try {
    return PrayerTimes.today(
      coords,
      utcOffset,
      calculationParameters: params,
    );
  } catch (_) {
    return null;
  }
});

/// Qibla direction in degrees clockwise from North.
/// Returns null when no location has been set.
final qiblahDirectionProvider = Provider<double?>((ref) {
  final loc = ref.watch(locationSettingsProvider);
  if (!loc.hasLocation) return null;

  final coords = Coordinates(loc.latitude!, loc.longitude!);
  return Qibla(coords).direction;
});

CalculationParameters _calcParams(String method) {
  switch (method) {
    case 'northAmerica':
      return CalculationMethod.northAmerica().getParameters();
    case 'egyptian':
      return CalculationMethod.egyptian().getParameters();
    case 'karachi':
      return CalculationMethod.karachi().getParameters();
    case 'ummAlQura':
      return CalculationMethod.ummAlQura().getParameters();
    case 'kuwait':
      return CalculationMethod.kuwait().getParameters();
    case 'qatar':
      return CalculationMethod.qatar().getParameters();
    case 'singapore':
      return CalculationMethod.singapore().getParameters();
    case 'turkey':
      return CalculationMethod.turkey().getParameters();
    case 'muslimWorldLeague':
    default:
      return CalculationMethod.muslimWorldLeague().getParameters();
  }
}
