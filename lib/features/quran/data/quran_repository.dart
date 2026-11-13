import 'dart:io';
import 'dart:math';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/models/ayah.dart';
import '../../../core/models/bookmark.dart';
import '../../../core/models/surah.dart';
import 'quran_json_parser.dart';

/// Reads/writes Quran data (Surahs, Ayahs, Bookmarks) in Isar.
///
/// Call [seed] whenever [isSeeded] is false to (re)populate the database
/// from the bundled JSON assets.
class QuranRepository {
  final Isar _isar;

  static const _positionFileName = 'last_quran_position.txt';
  static const _dataVersionFileName = 'quran_data_version.txt';

  /// Identifies the bundled Quran dataset. Bump whenever the files in
  /// assets/quran/ change so existing installs re-seed on next launch.
  ///
  /// 2 = full Tanzil Uthmani v1.1 + Saheeh International (1 was the stub).
  static const dataVersion = '2';

  static const expectedSurahCount = 114;
  static const expectedAyahCount = 6236;

  /// Rows written per step inside the seed transaction; small enough that
  /// the UI thread gets to draw frames between steps.
  static const _seedChunkSize = 400;

  QuranRepository(this._isar);

  // ── Seeding ───────────────────────────────────────────────────────────────

  /// Returns true only if the database holds the complete, current dataset.
  ///
  /// Databases seeded from the old stub (wrong row counts) or from an older
  /// dataset (version marker mismatch) report false and get re-seeded.
  Future<bool> isSeeded() async {
    if (await _isar.surahs.count() != expectedSurahCount) return false;
    if (await _isar.ayahs.count() != expectedAyahCount) return false;
    return await _readDataVersion() == dataVersion;
  }

  /// Replaces all Surahs + Ayahs with the bundled dataset in one
  /// transaction (all-or-nothing). Bookmarks and last-read are untouched.
  Future<void> seed() async {
    final data = await QuranJsonParser.load();

    await _isar.writeTxn(() async {
      await _isar.surahs.clear();
      await _isar.ayahs.clear();
      await _isar.surahs.putAll(data.surahs);
      for (var i = 0; i < data.ayahs.length; i += _seedChunkSize) {
        final end = min(i + _seedChunkSize, data.ayahs.length);
        await _isar.ayahs.putAll(data.ayahs.sublist(i, end));
      }
    });
    await _writeDataVersion();
  }

  Future<String?> _readDataVersion() async {
    try {
      final file = await _supportFile(_dataVersionFileName);
      return file.existsSync() ? file.readAsStringSync().trim() : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDataVersion() async {
    try {
      final file = await _supportFile(_dataVersionFileName);
      await file.writeAsString(dataVersion);
    } catch (_) {}
  }

  // ── Surahs ────────────────────────────────────────────────────────────────

  Future<List<Surah>> getAllSurahs() =>
      _isar.surahs.where().sortByNumber().findAll();

  // ── Ayahs ─────────────────────────────────────────────────────────────────

  Future<List<Ayah>> getAyahs(int surahNumber) => _isar.ayahs
      .filter()
      .surahNumberEqualTo(surahNumber)
      .sortByAyahNumber()
      .findAll();

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  /// Returns ayah numbers bookmarked within [surahNumber].
  Future<Set<int>> getBookmarkedAyahNumbers(int surahNumber) async {
    final bookmarks = await _isar.bookmarks
        .filter()
        .surahNumberEqualTo(surahNumber)
        .findAll();
    return {for (final b in bookmarks) b.ayahNumber};
  }

  Stream<List<Bookmark>> watchBookmarks() =>
      _isar.bookmarks.where().watch(fireImmediately: true);

  /// Toggles a bookmark for the given ayah. Adds if absent, removes if present.
  Future<void> toggleBookmark(int surahNumber, int ayahNumber) async {
    final existing = await _isar.bookmarks
        .filter()
        .surahNumberEqualTo(surahNumber)
        .ayahNumberEqualTo(ayahNumber)
        .findFirst();

    await _isar.writeTxn(() async {
      if (existing != null) {
        await _isar.bookmarks.delete(existing.id);
      } else {
        await _isar.bookmarks.put(Bookmark()
          ..surahNumber = surahNumber
          ..ayahNumber = ayahNumber);
      }
    });
  }

  // ── Last-read position ────────────────────────────────────────────────────

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    try {
      final file = await _supportFile(_positionFileName);
      await file.writeAsString('$surahNumber:$ayahNumber');
    } catch (_) {}
  }

  /// Returns the last-read (surahNumber, ayahNumber). Defaults to (1, 1).
  Future<({int surah, int ayah})> getLastRead() async {
    try {
      final file = await _supportFile(_positionFileName);
      if (!file.existsSync()) return (surah: 1, ayah: 1);
      final parts = file.readAsStringSync().trim().split(':');
      if (parts.length != 2) return (surah: 1, ayah: 1);
      return (surah: int.parse(parts[0]), ayah: int.parse(parts[1]));
    } catch (_) {
      return (surah: 1, ayah: 1);
    }
  }

  Future<File> _supportFile(String name) async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, name));
  }
}
