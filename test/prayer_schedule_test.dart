import 'package:adhan/adhan.dart';
import 'package:deen_audio/features/prayer/data/prayer_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

/// Same clock times every day: 05:00 / 06:30 / 12:30 / 15:45 / 18:20 / 19:50.
DayPrayerTimes _fixed(DateTime day) {
  DateTime at(int h, int m) => DateTime(day.year, day.month, day.day, h, m);
  return DayPrayerTimes(
    fajr: at(5, 0),
    sunrise: at(6, 30),
    dhuhr: at(12, 30),
    asr: at(15, 45),
    maghrib: at(18, 20),
    isha: at(19, 50),
  );
}

PrayerSchedule _at(int day, int hour, int minute) =>
    PrayerSchedule.at(DateTime(2026, 3, day, hour, minute), _fixed);

void main() {
  test('adhan itself reports no next prayer after Isha (why we need this)',
      () {
    final t = PrayerTimes(Coordinates(21.4225, 39.8262),
        DateComponents(2026, 3, 10), CalculationMethod.umm_al_qura.getParameters());
    expect(t.nextPrayerByDateTime(t.isha.add(const Duration(minutes: 5))),
        Prayer.none);
  });

  test('mid-afternoon: Dhuhr is current, Asr is next', () {
    final s = _at(10, 14, 0);
    expect(s.current, Prayer.dhuhr);
    expect(s.next, Prayer.asr);
    expect(s.nextTime, DateTime(2026, 3, 10, 15, 45));
    expect(s.nextIsOnAnotherDay, isFalse);
    expect(s.validUntil, DateTime(2026, 3, 10, 15, 45));
  });

  test('a prayer becomes current exactly at its time', () {
    expect(_at(10, 15, 44).current, Prayer.dhuhr);
    expect(_at(10, 15, 45).current, Prayer.asr);
    expect(_at(10, 15, 45).next, Prayer.maghrib);
  });

  test('after Isha the next prayer is tomorrow\'s Fajr', () {
    final s = _at(10, 22, 0);
    expect(s.current, Prayer.isha);
    expect(s.next, Prayer.fajr);
    expect(s.nextTime, DateTime(2026, 3, 11, 5, 0));
    expect(s.nextIsOnAnotherDay, isTrue);
    expect(s.validUntil, DateTime(2026, 3, 11),
        reason: 'the displayed day changes at midnight');
  });

  test('after midnight: new day, still Isha until Fajr', () {
    final s = _at(11, 0, 30);
    expect(s.date, DateTime(2026, 3, 11));
    expect(s.today.fajr, DateTime(2026, 3, 11, 5, 0));
    expect(s.current, Prayer.isha);
    expect(s.next, Prayer.fajr);
    expect(s.nextIsOnAnotherDay, isFalse);
    expect(s.validUntil, DateTime(2026, 3, 11, 5, 0));
  });

  test('Fajr ends at sunrise; sunrise is never offered as the next prayer',
      () {
    final beforeSunrise = _at(10, 5, 30);
    expect(beforeSunrise.current, Prayer.fajr);
    expect(beforeSunrise.next, Prayer.dhuhr);
    expect(beforeSunrise.validUntil, DateTime(2026, 3, 10, 6, 30));

    final afterSunrise = _at(10, 9, 0);
    expect(afterSunrise.current, Prayer.none);
    expect(afterSunrise.next, Prayer.dhuhr);
  });

  test('schedules compare by value so unchanged data does not rebuild the UI',
      () {
    expect(_at(10, 14, 0), _at(10, 14, 20));
    expect(_at(10, 14, 0), isNot(_at(10, 16, 0)));
  });

  test('real adhan times are ordered and roll over to the next day', () {
    final coords = Coordinates(21.4225, 39.8262);
    final params = CalculationMethod.umm_al_qura.getParameters();
    DayPrayerTimes timesFor(DateTime d) =>
        DayPrayerTimes.calculate(coords, params, d);

    final today = timesFor(DateTime(2026, 3, 10));
    final ordered = [
      today.fajr, today.sunrise, today.dhuhr,
      today.asr, today.maghrib, today.isha,
    ];
    for (var i = 1; i < ordered.length; i++) {
      expect(ordered[i].isAfter(ordered[i - 1]), isTrue);
    }

    final s = PrayerSchedule.at(
        today.isha.add(const Duration(minutes: 1)), timesFor);
    expect(s.current, Prayer.isha);
    expect(s.next, Prayer.fajr);
    expect(s.nextTime.isAfter(today.isha), isTrue);
    expect(s.nextTime.difference(today.fajr).inHours, inInclusiveRange(23, 25));
  });

  test('polar locations make the calculation throw (handled by the provider)',
      () {
    expect(
        () => DayPrayerTimes.calculate(Coordinates(78.22, 15.65),
            CalculationMethod.muslim_world_league.getParameters(),
            DateTime(2026, 6, 21)),
        throwsArgumentError);
  });
}
