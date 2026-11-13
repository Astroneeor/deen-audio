import 'package:drift/drift.dart';

import 'sync_columns.dart';
import 'tables/content_tables.dart';
import 'tables/device_tables.dart';
import 'tables/user_tables.dart';

part 'app_database.g.dart';

/// The app's single SQLite database. Opened once at startup (see
/// `openNativeConnection`) and provided through `appDatabaseProvider`; tests
/// pass an in-memory executor.
@DriftDatabase(tables: [
  // Bundled content
  Surahs,
  Ayahs,
  // User data (sync-ready)
  Bookmarks,
  Settings,
  Playlists,
  PlaylistItems,
  TrackStates,
  ReadingSessions,
  // Device-local
  Tracks,
  DownloadItems,
  DeviceSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
