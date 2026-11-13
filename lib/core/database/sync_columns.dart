import 'package:drift/drift.dart';

/// Stores a [DateTime] as UTC milliseconds since the epoch and always reads it
/// back as a UTC value. Used for every timestamp in the database so ordering
/// by time is a plain integer comparison and no local offset is ever stored.
class UtcDateTimeConverter extends TypeConverter<DateTime, int> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}

/// Columns every user-data (sync-ready) table carries. See
/// docs/superpowers/specs/2026-11-13-data-foundation-and-downloads-design.md,
/// "Sync-ready records".
mixin SyncColumns on Table {
  /// UUID generated on the device.
  TextColumn get id => text()();

  /// Set on every write (UTC).
  IntColumn get updatedAt => integer().map(const UtcDateTimeConverter())();

  /// Null while the row is live; the deletion time once soft-deleted.
  IntColumn get deletedAt =>
      integer().map(const UtcDateTimeConverter()).nullable()();

  /// Installation that last wrote the row.
  TextColumn get deviceId => text()();

  /// Null while the app runs as the local user.
  TextColumn get userId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
