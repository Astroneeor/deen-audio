import 'package:adhan/adhan.dart';
import 'package:deen_audio/features/prayer/data/prayer_schedule.dart';
import 'package:deen_audio/features/prayer/providers/prayer_providers.dart';
import 'package:deen_audio/features/settings/providers/settings_providers.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/empty_settings_repository.dart';

class _FixedLocation extends LocationNotifier {
  _FixedLocation(LocationSettings settings) : super(EmptySettingsRepository()) {
    state = settings;
  }
}

const _makkah = LocationSettings(
    latitude: 21.4225, longitude: 39.8262, calculationMethod: 'ummAlQura');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Runs [body] with a container whose clock starts at [start] and advances
  /// with fake time.
  void withContainer(
    DateTime start,
    LocationSettings location,
    void Function(FakeAsync async, ProviderContainer container) body,
  ) {
    fakeAsync((async) {
      final container = ProviderContainer(overrides: [
        clockProvider.overrideWithValue(() => start.add(async.elapsed)),
        locationSettingsProvider
            .overrideWith((ref) => _FixedLocation(location)),
      ]);
      body(async, container);
      container.dispose();
      async.flushMicrotasks();
    });
  }

  test('no location: no schedule and no qibla', () {
    withContainer(DateTime(2026, 3, 10, 12), const LocationSettings(),
        (async, c) {
      expect(c.read(prayerScheduleProvider), isNull);
      expect(c.read(qiblahDirectionProvider), isNull);
    });
  });

  test('polar location: no schedule instead of an exception', () {
    withContainer(DateTime(2026, 6, 21, 12),
        const LocationSettings(latitude: 78.22, longitude: 15.65), (async, c) {
      expect(c.read(prayerScheduleProvider), isNull);
      expect(c.read(qiblahDirectionProvider), isNotNull);
    });
  });

  test('rolls over to the new day at midnight while the app stays open', () {
    withContainer(DateTime(2026, 3, 10, 23, 58), _makkah, (async, c) {
      final seen = <PrayerSchedule?>[];
      c.listen(prayerScheduleProvider, (_, next) => seen.add(next),
          fireImmediately: true);
      expect(seen.single!.date, DateTime(2026, 3, 10));

      async.elapse(const Duration(minutes: 3));

      expect(seen.last!.date, DateTime(2026, 3, 11));
      expect(seen.last!.today, isNot(seen.first!.today));
    });
  });

  test('advances current / next when a prayer time passes', () {
    final coords = Coordinates(_makkah.latitude!, _makkah.longitude!);
    final asr = DayPrayerTimes.calculate(
            coords,
            CalculationMethod.umm_al_qura.getParameters(),
            DateTime(2026, 3, 10))
        .asr;

    withContainer(asr.subtract(const Duration(minutes: 30)), _makkah,
        (async, c) {
      final seen = <PrayerSchedule?>[];
      c.listen(prayerScheduleProvider, (_, next) => seen.add(next),
          fireImmediately: true);
      expect(seen.single!.current, Prayer.dhuhr);
      expect(seen.single!.next, Prayer.asr);

      async.elapse(const Duration(minutes: 29));
      expect(seen, hasLength(1), reason: 'nothing changed, no rebuilds');

      async.elapse(const Duration(minutes: 2));
      expect(seen.last!.current, Prayer.asr);
      expect(seen.last!.next, Prayer.maghrib);
    });
  });

  test('qibla bearings match known values', () {
    double bearing(double lat, double lng) {
      late double result;
      withContainer(DateTime(2026, 3, 10),
          LocationSettings(latitude: lat, longitude: lng), (async, c) {
        result = c.read(qiblahDirectionProvider)!;
      });
      return result;
    }

    expect(bearing(51.5074, -0.1278), closeTo(119.0, 0.5)); // London
    expect(bearing(40.7128, -74.0060), closeTo(58.5, 0.5)); // New York
    expect(bearing(-6.2, 106.8), closeTo(295.2, 0.5)); // Jakarta
  });
}
