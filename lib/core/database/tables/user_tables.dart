import 'package:drift/drift.dart';

import '../sync_columns.dart';

// User data: sync-ready. Every table has the SyncColumns (UUID `id` primary
// key, updated_at, deleted_at, device_id, user_id). Tables with a natural key
// declare it unique, so re-adding something soft-deleted revives the same row.

/// Saved ayahs. Natural key: (surah_number, ayah_number).
@DataClassName('BookmarkRow')
class Bookmarks extends Table with SyncColumns {
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {surahNumber, ayahNumber},
      ];
}

/// User preferences, one row per key; `value` is JSON text.
@DataClassName('SettingRow')
class Settings extends Table with SyncColumns {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {key},
      ];
}

/// User playlists.
@DataClassName('PlaylistRow')
class Playlists extends Table with SyncColumns {
  TextColumn get name => text()();
  IntColumn get createdAt => integer().map(const UtcDateTimeConverter())();
}

/// Ordered playlist entries. Tracks are referenced by track key (catalog file
/// id or library-relative path), never by a local row id.
///
/// (playlist_id, position) is indexed for ordering only, not unique: a
/// soft-deleted row keeps its old position, and reordering passes through
/// transient duplicates.
@DataClassName('PlaylistItemRow')
@TableIndex(name: 'playlist_items_order', columns: {#playlistId, #position})
class PlaylistItems extends Table with SyncColumns {
  TextColumn get playlistId => text()();
  IntColumn get position => integer()();
  TextColumn get trackKey => text()();
}

/// Per-track user state that must survive a rescan and travel between
/// devices. Natural key: track_key.
@DataClassName('TrackStateRow')
class TrackStates extends Table with SyncColumns {
  TextColumn get trackKey => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get lastPlayed =>
      integer().map(const UtcDateTimeConverter()).nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {trackKey},
      ];
}

/// Reading history. Created now; written by the reading-tracking step later.
@DataClassName('ReadingSessionRow')
class ReadingSessions extends Table with SyncColumns {
  IntColumn get startedAt => integer().map(const UtcDateTimeConverter())();
  IntColumn get endedAt =>
      integer().map(const UtcDateTimeConverter()).nullable()();
  IntColumn get surahNumber => integer()();
  IntColumn get fromAyah => integer()();
  IntColumn get toAyah => integer()();
}
