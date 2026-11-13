import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

/// Device-local key/value settings (never synced): device id, library folder,
/// Quran data version, one-time-reset marker.
class DeviceSettingsRepository {
  DeviceSettingsRepository(this._db, {String Function()? newId})
      : _newId = newId ?? const Uuid().v4;

  static const deviceIdKey = 'device.id';

  final AppDatabase _db;
  final String Function() _newId;

  Future<String?> read(String key) async {
    final row = await (_db.select(_db.deviceSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) =>
      _db.into(_db.deviceSettings).insertOnConflictUpdate(
          DeviceSettingsCompanion.insert(key: key, value: value));

  /// This installation's UUID, generated and stored on first call.
  Future<String> deviceId() => _db.transaction(() async {
        final existing = await read(deviceIdKey);
        if (existing != null && existing.isNotEmpty) return existing;
        final id = _newId();
        await _db.into(_db.deviceSettings).insert(
              DeviceSettingsCompanion.insert(key: deviceIdKey, value: id),
              mode: InsertMode.insertOrReplace,
            );
        return id;
      });
}
