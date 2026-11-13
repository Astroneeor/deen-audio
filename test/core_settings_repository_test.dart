import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/database/device_settings_repository.dart';
import 'package:deen_audio/core/database/settings_repository.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/core/sync/sync_stamper.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_database.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late SettingsRepository repo;
  var ids = 0;

  setUp(() {
    db = testDatabase();
    now = DateTime.utc(2026, 11, 13, 9);
    final stamper = SyncStamper(
      session: const LocalAuthSession(deviceId: 'device-1'),
      now: () => now,
      newId: () => 'id-${ids++}',
    );
    repo = SettingsRepository(db, stamper);
  });
  tearDown(() => db.close());

  Future<List<SettingRow>> rowsFor(String key) =>
      (db.select(db.settings)..where((t) => t.key.equals(key))).get();

  group('SettingsRepository', () {
    test('write then read round-trips a map', () async {
      final value = {'lat': 51.5, 'lng': -0.12, 'city': 'London', 'ok': true};
      await repo.write('prayer.location', value);
      expect(await repo.read('prayer.location'), value);
    });

    test('read of a missing key is null', () async {
      expect(await repo.read('nothing'), isNull);
    });

    test('write stamps updatedAt (UTC) and deviceId', () async {
      await repo.write('quran.fontSize', 30.0);
      final row = (await rowsFor('quran.fontSize')).single;
      expect(row.updatedAt.isUtc, isTrue);
      expect(row.updatedAt, now);
      expect(row.deviceId, 'device-1');
      expect(row.userId, isNull);
      expect(row.deletedAt, isNull);

      now = now.add(const Duration(minutes: 5));
      await repo.write('quran.fontSize', 32.0);
      final updated = (await rowsFor('quran.fontSize')).single;
      expect(updated.updatedAt, now);
      expect(updated.id, row.id);
    });

    test('remove hides the value and sets deletedAt', () async {
      await repo.write('k', 'v');
      now = now.add(const Duration(seconds: 1));
      await repo.remove('k');
      expect(await repo.read('k'), isNull);
      final row = (await rowsFor('k')).single;
      expect(row.deletedAt, now);
      expect(row.updatedAt, now);
    });

    test('write after remove leaves exactly one live row', () async {
      await repo.write('k', 1);
      await repo.remove('k');
      await repo.write('k', 2);
      final rows = await rowsFor('k');
      expect(rows, hasLength(1));
      expect(rows.single.deletedAt, isNull);
      expect(await repo.read('k'), 2);
    });

    test('watch emits on change', () async {
      final expectation =
          expectLater(repo.watch('k'), emitsInOrder([null, 1, 2, null]));
      await pumpEventQueue();
      await repo.write('k', 1);
      await pumpEventQueue();
      await repo.write('k', 2);
      await pumpEventQueue();
      await repo.remove('k');
      await expectation;
    });
  });

  group('DeviceSettingsRepository', () {
    test('write then read', () async {
      final device = DeviceSettingsRepository(db);
      expect(await device.read('library.folder'), isNull);
      await device.write('library.folder', '/home/me/HalalAudio');
      await device.write('library.folder', '/data/audio');
      expect(await device.read('library.folder'), '/data/audio');
    });

    test('deviceId() returns the same value twice', () async {
      final device = DeviceSettingsRepository(db);
      final first = await device.deviceId();
      expect(first, isNotEmpty);
      expect(await device.deviceId(), first);
      expect(await DeviceSettingsRepository(db).deviceId(), first);
    });
  });
}
