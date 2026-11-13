import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/device_settings_repository.dart';
import '../../../core/database/settings_repository.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/bookmark.dart';
import '../../../core/models/surah.dart';
import '../../../core/sync/sync_stamper.dart';
import 'quran_json_parser.dart';

/// Reads/writes Quran data (surahs, ayahs, bookmarks, last-read position) in
/// the SQLite [AppDatabase].
///
/// Call [seed] whenever [isSeeded] is false to (re)populate the database
/// from the bundled JSON assets.
class QuranRepository {
  QuranRepository(this._db, this._stamper, this._settings, this._device);

  final AppDatabase _db;
  final SyncStamper _stamper;
  final SettingsRepository _settings;
  final DeviceSettingsRepository _device;

  static const _lastReadKey = 'quran.lastRead';
  static const _dataVersionKey = 'quran.dataVersion';

  /// Identifies the bundled Quran dataset. Bump whenever the files in
  /// assets/quran/ change so existing installs re-seed on next launch.
  ///
  /// 2 = full Tanzil Uthmani v1.1 + Saheeh International (1 was the stub).
  static const dataVersion = '2';

  static const expectedSurahCount = 114;
  static const expectedAyahCount = 6236;

  /// Rows per insert batch inside the seed transaction.
  static const _seedChunkSize = 400;

  // ── Seeding ───────────────────────────────────────────────────────────────

  Future<int> _count<T extends HasResultSet, D>(
      ResultSetImplementation<T, D> t) async {
    final n = countAll();
    final row = await (_db.selectOnly(t)..addColumns([n])).getSingle();
    return row.read(n)!;
  }

  /// Returns true only if the database holds the complete, current dataset.
  Future<bool> isSeeded() async {
    if (await _count(_db.surahs) != expectedSurahCount) return false;
    if (await _count(_db.ayahs) != expectedAyahCount) return false;
    return await _device.read(_dataVersionKey) == dataVersion;
  }

  /// Replaces all surahs + ayahs with the bundled dataset in one transaction
  /// (all-or-nothing). Bookmarks and last-read are untouched.
  Future<void> seed() async {
    final data = await QuranJsonParser.load();
    await _db.transaction(() async {
      await _db.delete(_db.surahs).go();
      await _db.delete(_db.ayahs).go();
      await _db.batch((b) => b.insertAll(_db.surahs, [
            for (final s in data.surahs)
              SurahsCompanion.insert(
                number: Value(s.number),
                name: s.name,
                englishName: s.englishName,
                englishNameTranslation: s.englishNameTranslation,
                numberOfAyahs: s.numberOfAyahs,
                revelationType: s.revelationType,
              ),
          ]));
      for (var i = 0; i < data.ayahs.length; i += _seedChunkSize) {
        final chunk =
            data.ayahs.sublist(i, min(i + _seedChunkSize, data.ayahs.length));
        await _db.batch((b) => b.insertAll(_db.ayahs, [
              for (final a in chunk)
                AyahsCompanion.insert(
                  surahNumber: a.surahNumber,
                  ayahNumber: a.ayahNumber,
                  arabicText: a.arabicText,
                  translation: Value(a.translation),
                ),
            ]));
      }
      await _device.write(_dataVersionKey, dataVersion);
    });
  }

  // ── Surahs ────────────────────────────────────────────────────────────────

  Future<List<Surah>> getAllSurahs() async {
    final rows = await (_db.select(_db.surahs)
          ..orderBy([(t) => OrderingTerm.asc(t.number)]))
        .get();
    return [
      for (final r in rows)
        Surah()
          ..number = r.number
          ..name = r.name
          ..englishName = r.englishName
          ..englishNameTranslation = r.englishNameTranslation
          ..numberOfAyahs = r.numberOfAyahs
          ..revelationType = r.revelationType,
    ];
  }

  // ── Ayahs ─────────────────────────────────────────────────────────────────

  Future<List<Ayah>> getAyahs(int surahNumber) async {
    final rows = await (_db.select(_db.ayahs)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([(t) => OrderingTerm.asc(t.ayahNumber)]))
        .get();
    return [
      for (final r in rows)
        Ayah()
          ..surahNumber = r.surahNumber
          ..ayahNumber = r.ayahNumber
          ..arabicText = r.arabicText
          ..translation = r.translation,
    ];
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  /// Returns ayah numbers bookmarked within [surahNumber].
  Future<Set<int>> getBookmarkedAyahNumbers(int surahNumber) async {
    final rows = await (_db.select(_db.bookmarks)
          ..where(
              (t) => t.surahNumber.equals(surahNumber) & t.deletedAt.isNull()))
        .get();
    return {for (final r in rows) r.ayahNumber};
  }

  /// Emits the live (not soft-deleted) bookmarks, now and on every change.
  Stream<List<Bookmark>> watchBookmarks() =>
      (_db.select(_db.bookmarks)..where((t) => t.deletedAt.isNull()))
          .watch()
          .map((rows) => [
                for (final r in rows)
                  Bookmark()
                    ..surahNumber = r.surahNumber
                    ..ayahNumber = r.ayahNumber
                    ..savedAt = r.updatedAt,
              ]);

  /// Toggles a bookmark: adds (or revives) if absent, soft-deletes if present.
  Future<void> toggleBookmark(int surahNumber, int ayahNumber) =>
      _db.transaction(() async {
        final existing = await (_db.select(_db.bookmarks)
              ..where((t) =>
                  t.surahNumber.equals(surahNumber) &
                  t.ayahNumber.equals(ayahNumber)))
            .getSingleOrNull();
        final now = _stamper.nowUtc();
        final stamp = BookmarksCompanion(
          updatedAt: Value(now),
          deletedAt: Value(
              existing == null || existing.deletedAt != null ? null : now),
          deviceId: Value(_stamper.deviceId),
          userId: Value(_stamper.userId),
        );
        if (existing == null) {
          await _db.into(_db.bookmarks).insert(stamp.copyWith(
                id: Value(_stamper.newId()),
                surahNumber: Value(surahNumber),
                ayahNumber: Value(ayahNumber),
              ));
        } else {
          await (_db.update(_db.bookmarks)
                ..where((t) => t.id.equals(existing.id)))
              .write(stamp);
        }
      });

  // ── Last-read position ────────────────────────────────────────────────────

  Future<void> saveLastRead(int surahNumber, int ayahNumber) =>
      _settings.write(_lastReadKey, {'surah': surahNumber, 'ayah': ayahNumber});

  /// Returns the last-read position, or null if none is stored or it points
  /// outside the Quran (surah not in 1–114, ayah beyond the surah's count).
  Future<({int surah, int ayah})?> getLastRead() async {
    final v = await _settings.read(_lastReadKey);
    if (v is! Map) return null;
    final surah = v['surah'];
    final ayah = v['ayah'];
    if (surah is! int || ayah is! int || surah < 1 || surah > 114 || ayah < 1) {
      return null;
    }
    final row = await (_db.select(_db.surahs)
          ..where((t) => t.number.equals(surah)))
        .getSingleOrNull();
    if (row == null || ayah > row.numberOfAyahs) return null;
    return (surah: surah, ayah: ayah);
  }
}
