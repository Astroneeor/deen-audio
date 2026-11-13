import 'package:deen_audio/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import 'support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('opens in-memory database', () async {
    final row = await db.customSelect('SELECT 1 AS one').getSingle();
    expect(row.read<int>('one'), 1);
  });

  test('every table exists', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll(<String>[
        'surahs',
        'ayahs',
        'bookmarks',
        'settings',
        'playlists',
        'playlist_items',
        'track_states',
        'reading_sessions',
        'tracks',
        'download_items',
        'device_settings',
      ]),
    );
  });

  test('user-data tables carry the sync columns', () async {
    const syncColumns = [
      'id',
      'updated_at',
      'deleted_at',
      'device_id',
      'user_id'
    ];
    for (final table in [
      'bookmarks',
      'settings',
      'playlists',
      'playlist_items',
      'track_states',
      'reading_sessions',
    ]) {
      final cols = await db.customSelect('PRAGMA table_info($table)').get();
      final names = cols.map((c) => c.read<String>('name')).toList();
      expect(names, containsAll(syncColumns), reason: table);
      final pk = cols.where((c) => c.read<int>('pk') > 0).toList();
      expect(pk.map((c) => c.read<String>('name')), ['id'], reason: table);
    }
  });

  test('two bookmarks with the same surah/ayah violate uniqueness', () async {
    BookmarksCompanion bookmark(String id) => BookmarksCompanion.insert(
          id: id,
          updatedAt: DateTime.utc(2026, 11, 13),
          deviceId: 'device-1',
          surahNumber: 1,
          ayahNumber: 3,
        );

    await db.into(db.bookmarks).insert(bookmark('a'));
    expect(
      () => db.into(db.bookmarks).insert(bookmark('b')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('timestamps round-trip as UTC with millisecond precision', () async {
    final at = DateTime.utc(2026, 11, 13, 8, 30, 15, 123);
    await db.into(db.bookmarks).insert(BookmarksCompanion.insert(
          id: 'a',
          updatedAt: at,
          deviceId: 'device-1',
          surahNumber: 2,
          ayahNumber: 255,
          deletedAt: Value(at.toLocal()),
        ));
    final row = await db.select(db.bookmarks).getSingle();
    expect(row.updatedAt.isUtc, isTrue);
    expect(row.updatedAt, at);
    expect(row.deletedAt!.isUtc, isTrue);
    expect(row.deletedAt, at);
  });
}
