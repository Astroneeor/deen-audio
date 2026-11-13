import 'package:drift/drift.dart';

// Device-local tables: never synced.

/// The playable library: scanned files and completed downloads.
@DataClassName('TrackRow')
class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();

  /// `TrackType` enum name: quran | adhkar | nasheed | whiteNoise.
  TextColumn get type => text()();

  /// Absolute for scanned files; relative to the FileStore base for downloads.
  TextColumn get filePath => text()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get surahNumber => text().nullable()();

  /// `lib:<path relative to library folder>` or `dl:<catalog file id>`.
  TextColumn get trackKey => text().unique()();

  /// `scanned` | `downloaded`.
  TextColumn get source => text()();
}

/// One row per catalog file the user asked to download.
@DataClassName('DownloadItemRow')
class DownloadItems extends Table {
  /// Catalog file id.
  TextColumn get fileId => text()();
  TextColumn get packId => text()();
  TextColumn get url => text()();

  /// Relative to the FileStore base directory.
  TextColumn get relativePath => text()();
  IntColumn get bytesTotal => integer().nullable()();
  IntColumn get bytesDone => integer().withDefault(const Constant(0))();

  /// queued | running | paused | done | failed.
  TextColumn get status => text()();
  TextColumn get error => text().nullable()();
  TextColumn get checksum => text().nullable()();

  @override
  Set<Column> get primaryKey => {fileId};
}

/// Device-only key/value settings (device id, library folder, data version,
/// one-time-reset marker).
@DataClassName('DeviceSettingRow')
class DeviceSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
