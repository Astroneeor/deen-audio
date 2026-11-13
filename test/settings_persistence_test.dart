import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/database/settings_repository.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/core/sync/sync_stamper.dart';
import 'package:deen_audio/features/settings/providers/settings_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_database.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;
  var ids = 0;

  setUp(() {
    db = testDatabase();
    repo = SettingsRepository(
      db,
      SyncStamper(
        session: const LocalAuthSession(deviceId: 'd'),
        now: () => DateTime.utc(2026, 11, 13),
        newId: () => 'id-${ids++}',
      ),
    );
  });
  tearDown(() => db.close());

  QuranFontSizeNotifier fontNotifier() => QuranFontSizeNotifier(repo);
  LocationNotifier locationNotifier() => LocationNotifier(repo);

  group('Quran font size', () {
    test('a saved size is read back by a fresh notifier', () async {
      final n = fontNotifier();
      await n.loaded;
      await n.set(40);

      final again = fontNotifier();
      await again.loaded;
      expect(again.state, 40.0);
      expect(await repo.read('quran.fontSize'), 40.0);
    });

    test('missing, non-numeric or out-of-range values fall back to the default',
        () async {
      for (final stored in <Object?>['abc', '30', 9000, -3, null, true]) {
        await repo.write('quran.fontSize', stored);
        final n = fontNotifier();
        await n.loaded;
        expect(n.state, 26.0, reason: 'stored $stored');
      }
      await repo.remove('quran.fontSize');
      final n = fontNotifier();
      await n.loaded;
      expect(n.state, 26.0);
    });

    test('a change made before the saved value has loaded is not undone',
        () async {
      await repo.write('quran.fontSize', 30.0);
      final n = fontNotifier();
      // e.g. slider touched while the saved value is still being read
      final saved = n.set(40);
      await n.loaded;
      await saved;
      expect(n.state, 40.0);
      expect(await repo.read('quran.fontSize'), 40.0);
    });

    test('dragging the slider (many rapid writes) persists the final value',
        () async {
      final n = fontNotifier();
      await n.loaded;
      for (var i = 0; i < 300; i++) {
        n.set(18 + (i % 31).toDouble());
      }
      await n.set(33);
      expect(n.state, 33.0);
      expect(await repo.read('quran.fontSize'), 33.0);
    });
  });

  group('Prayer location', () {
    test('round-trips location and method', () async {
      final n = locationNotifier();
      await n.loaded;
      await n.setLocation(21.3891, 39.8579);
      await n.setMethod('ummAlQura');

      final again = locationNotifier();
      await again.loaded;
      expect(again.state.latitude, 21.3891);
      expect(again.state.longitude, 39.8579);
      expect(again.state.calculationMethod, 'ummAlQura');
    });

    test('missing or malformed stored values fall back to "no location"',
        () async {
      for (final stored in <Object?>[
        null,
        '',
        '{',
        [],
        'x',
        {'latitude': 'north'}
      ]) {
        await repo.write('prayer.location', stored);
        final n = locationNotifier();
        await n.loaded;
        expect(n.state.hasLocation, isFalse, reason: 'stored $stored');
        expect(n.state.calculationMethod, 'muslimWorldLeague');
      }
    });

    test('an unknown calculation method is replaced by the default', () async {
      await repo.write('prayer.location',
          {'latitude': 1.0, 'longitude': 2.0, 'calculationMethod': 'bogus'});
      final n = locationNotifier();
      await n.loaded;
      expect(n.state.hasLocation, isTrue);
      expect(n.state.calculationMethod, 'muslimWorldLeague',
          reason: 'the settings dropdown asserts on values it does not list');
    });

    test('out-of-range coordinates (latitude 500) load as "not set"', () async {
      await repo.write('prayer.location', {'latitude': 500, 'longitude': 2.0});
      final n = locationNotifier();
      await n.loaded;
      expect(n.state.hasLocation, isFalse);
    });

    test('a change made before the saved value has loaded is not undone',
        () async {
      await repo.write('prayer.location',
          {'latitude': 1.0, 'longitude': 2.0, 'calculationMethod': 'turkey'});
      final n = locationNotifier();
      final saved = n.setLocation(10, 20);
      await n.loaded;
      await saved;
      expect(n.state.latitude, 10);
      expect(n.state.longitude, 20);
      final stored = await repo.read('prayer.location') as Map;
      expect(stored['latitude'], 10);
    });

    test('two rapid writes leave the last value', () async {
      final n = locationNotifier();
      await n.loaded;
      n.setLocation(1, 2);
      await n.setLocation(3, 4);
      final again = locationNotifier();
      await again.loaded;
      expect(again.state.latitude, 3);
      expect(again.state.longitude, 4);
    });
  });
}
