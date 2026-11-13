import 'package:adhan/adhan.dart';
import 'package:deen_audio/features/prayer/data/prayer_schedule.dart';
import 'package:deen_audio/features/prayer/providers/prayer_providers.dart';
import 'package:deen_audio/features/prayer/ui/prayer_screen.dart';
import 'package:deen_audio/features/settings/providers/settings_providers.dart';
import 'package:flutter/material.dart';
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

DayPrayerTimes _makkahTimes(DateTime day) => DayPrayerTimes.calculate(
    Coordinates(_makkah.latitude!, _makkah.longitude!),
    CalculationMethod.umm_al_qura.getParameters(),
    day);

Future<void> _pump(
  WidgetTester tester, {
  required LocationSettings location,
  required DateTime now,
}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(() => now),
      locationSettingsProvider.overrideWith((ref) => _FixedLocation(location)),
    ],
    child: const MaterialApp(home: Scaffold(body: PrayerScreen())),
  ));
  await tester.pump();
}

/// The row (name + optional badge + time) for a prayer name.
Finder _row(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(Row)).first;

void main() {
  testWidgets('without a location it asks for one', (tester) async {
    await _pump(tester,
        location: const LocationSettings(), now: DateTime(2026, 3, 10, 12));
    expect(find.text('Location not set'), findsOneWidget);
    expect(find.text('Fajr'), findsNothing);
  });

  testWidgets('a polar location is reported as such, not as "not set"',
      (tester) async {
    await _pump(tester,
        location: const LocationSettings(latitude: 78.22, longitude: 15.65),
        now: DateTime(2026, 6, 21, 12));
    expect(find.text('Location not set'), findsNothing);
    expect(find.text('Prayer times unavailable here'), findsOneWidget);
    expect(find.textContaining('from North'), findsOneWidget);
  });

  testWidgets('badges the next prayer during the day', (tester) async {
    final today = _makkahTimes(DateTime(2026, 3, 10));
    await _pump(tester,
        location: _makkah, now: today.dhuhr.add(const Duration(minutes: 10)));

    expect(find.descendant(of: _row('Asr'), matching: find.text('Next')),
        findsOneWidget);
    expect(find.textContaining('Next'), findsOneWidget);
  });

  testWidgets('after Isha, Fajr is badged as next', (tester) async {
    final today = _makkahTimes(DateTime(2026, 3, 10));
    await _pump(tester,
        location: _makkah, now: today.isha.add(const Duration(minutes: 10)));

    expect(
        find.descendant(
            of: _row('Fajr'), matching: find.textContaining('Next')),
        findsOneWidget);
  });

  testWidgets('says plainly that the qiblah diagram is not a live compass',
      (tester) async {
    await _pump(tester, location: _makkah, now: DateTime(2026, 3, 10, 12));
    expect(find.textContaining('not a live compass'), findsOneWidget);
  });

  testWidgets('does not overflow in a narrow content area', (tester) async {
    tester.view.physicalSize = const Size(420, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final today = _makkahTimes(DateTime(2026, 3, 10));
    await _pump(tester,
        location: _makkah, now: today.isha.add(const Duration(minutes: 10)));
    expect(tester.takeException(), isNull);

    await _pump(tester,
        location: const LocationSettings(), now: DateTime(2026, 3, 10, 12));
    expect(tester.takeException(), isNull);
  });
}
