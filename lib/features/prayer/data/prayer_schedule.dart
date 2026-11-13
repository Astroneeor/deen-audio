import 'package:adhan/adhan.dart';

/// The six daily times for one calendar day, as local [DateTime]s.
class DayPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DayPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Calculates the times for the calendar day of [day] at [coordinates].
  /// Throws [ArgumentError] where adhan cannot compute them (polar regions).
  factory DayPrayerTimes.calculate(
    Coordinates coordinates,
    CalculationParameters parameters,
    DateTime day,
  ) {
    final t = PrayerTimes(coordinates, DateComponents.from(day), parameters);
    return DayPrayerTimes(
      fajr: t.fajr,
      sunrise: t.sunrise,
      dhuhr: t.dhuhr,
      asr: t.asr,
      maghrib: t.maghrib,
      isha: t.isha,
    );
  }

  DateTime timeOf(Prayer prayer) => switch (prayer) {
        Prayer.fajr => fajr,
        Prayer.sunrise => sunrise,
        Prayer.dhuhr => dhuhr,
        Prayer.asr => asr,
        Prayer.maghrib => maghrib,
        Prayer.isha => isha,
        Prayer.none => throw ArgumentError.value(prayer, 'prayer'),
      };

  static const _order = [
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  Iterable<({Prayer prayer, DateTime time})> get _events =>
      _order.map((p) => (prayer: p, time: timeOf(p)));

  @override
  bool operator ==(Object other) =>
      other is DayPrayerTimes &&
      _order.every((p) => timeOf(p) == other.timeOf(p));

  @override
  int get hashCode => Object.hashAll(_order.map(timeOf));
}

/// What the prayer screen shows at one moment: today's times plus which
/// prayer is current and which comes next.
class PrayerSchedule {
  /// The local calendar day [today] belongs to.
  final DateTime date;
  final DayPrayerTimes today;

  /// The prayer whose time it is now, or [Prayer.none] between sunrise and
  /// Dhuhr. After midnight this is still Isha (yesterday's) until Fajr.
  final Prayer current;

  /// The upcoming prayer — never [Prayer.none] or sunrise. After Isha this
  /// is tomorrow's Fajr.
  final Prayer next;
  final DateTime nextTime;

  /// When this schedule stops being accurate: the next prayer/sunrise time
  /// or local midnight, whichever comes first.
  final DateTime validUntil;

  const PrayerSchedule({
    required this.date,
    required this.today,
    required this.current,
    required this.next,
    required this.nextTime,
    required this.validUntil,
  });

  /// True when [nextTime] is not one of the times listed for [today]
  /// (i.e. it is tomorrow's Fajr).
  bool get nextIsOnAnotherDay => today.timeOf(next) != nextTime;

  /// Builds the schedule for the instant [now]. [timesFor] supplies the
  /// times of any calendar day; yesterday and tomorrow are consulted so the
  /// result is right across midnight and after Isha.
  factory PrayerSchedule.at(
    DateTime now,
    DayPrayerTimes Function(DateTime day) timesFor,
  ) {
    final date = DateTime(now.year, now.month, now.day);
    final today = timesFor(date);
    final events = [
      ...timesFor(DateTime(now.year, now.month, now.day - 1))._events,
      ...today._events,
      ...timesFor(DateTime(now.year, now.month, now.day + 1))._events,
    ]..sort((a, b) => a.time.compareTo(b.time));

    final past = events.where((e) => !e.time.isAfter(now));
    final upcoming = events.where((e) => e.time.isAfter(now));
    final next = upcoming.firstWhere((e) => e.prayer != Prayer.sunrise);
    final midnight = DateTime(now.year, now.month, now.day + 1);

    final last = past.isEmpty ? Prayer.none : past.last.prayer;
    return PrayerSchedule(
      date: date,
      today: today,
      current: last == Prayer.sunrise ? Prayer.none : last,
      next: next.prayer,
      nextTime: next.time,
      validUntil: upcoming.first.time.isBefore(midnight)
          ? upcoming.first.time
          : midnight,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerSchedule &&
      date == other.date &&
      today == other.today &&
      current == other.current &&
      next == other.next &&
      nextTime == other.nextTime &&
      validUntil == other.validUntil;

  @override
  int get hashCode =>
      Object.hash(date, today, current, next, nextTime, validUntil);
}
