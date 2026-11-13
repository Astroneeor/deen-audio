import 'dart:convert';

import 'package:drift/drift.dart';

import '../sync/sync_stamper.dart';
import 'app_database.dart';

/// User settings (sync-ready), one row per key with a JSON-encoded value.
/// `remove` soft-deletes; a later `write` revives the same row.
class SettingsRepository {
  SettingsRepository(this._db, this._stamper);

  final AppDatabase _db;
  final SyncStamper _stamper;

  SimpleSelectStatement<$SettingsTable, SettingRow> _byKey(String key) =>
      _db.select(_db.settings)..where((t) => t.key.equals(key));

  static Object? _decode(String? json) =>
      json == null ? null : jsonDecode(json);

  static String? _liveValue(SettingRow? row) =>
      row == null || row.deletedAt != null ? null : row.value;

  /// The decoded value, or null if the key is missing or removed.
  Future<Object?> read(String key) async =>
      _decode(_liveValue(await _byKey(key).getSingleOrNull()));

  /// Emits the current value now and again whenever it changes.
  Stream<Object?> watch(String key) =>
      _byKey(key).watchSingleOrNull().map(_liveValue).distinct().map(_decode);

  /// Stores [jsonValue] (anything `jsonEncode` accepts) under [key].
  Future<void> write(String key, Object? jsonValue) {
    final encoded = jsonEncode(jsonValue);
    return _db.transaction(() async {
      final existing = await _byKey(key).getSingleOrNull();
      final stamp = SettingsCompanion(
        value: Value(encoded),
        updatedAt: Value(_stamper.nowUtc()),
        deletedAt: const Value(null),
        deviceId: Value(_stamper.deviceId),
        userId: Value(_stamper.userId),
      );
      if (existing == null) {
        await _db.into(_db.settings).insert(
              stamp.copyWith(id: Value(_stamper.newId()), key: Value(key)),
            );
      } else {
        await (_db.update(_db.settings)..where((t) => t.id.equals(existing.id)))
            .write(stamp);
      }
    });
  }

  /// Soft-deletes [key] so the deletion can sync; no-op if absent or removed.
  Future<void> remove(String key) {
    final now = _stamper.nowUtc();
    return (_db.update(_db.settings)
          ..where((t) => t.key.equals(key) & t.deletedAt.isNull()))
        .write(SettingsCompanion(
      updatedAt: Value(now),
      deletedAt: Value(now),
      deviceId: Value(_stamper.deviceId),
      userId: Value(_stamper.userId),
    ));
  }
}
