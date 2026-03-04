import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/models/ayah.dart';
import '../../../core/models/bookmark.dart';
import '../../../core/models/surah.dart';
import 'quran_json_parser.dart';

/// Reads/writes Quran data (Surahs, Ayahs, Bookmarks) in Isar.
///
/// Call [seed] once on first launch to populate from bundled JSON assets.
class QuranRepository {
  final Isar _isar;

  static const _positionFileName = 'last_quran_position.txt';

  QuranRepository(this._isar);

  // ── Seeding ───────────────────────────────────────────────────────────────

  /// Returns true if Quran data is already in the database with
  /// transliterations (schema v2). Forces re-seed when upgrading from old data.
  Future<bool> isSeeded() async {
    final surahCount = await _isar.surahs.count();
    if (surahCount == 0) return false;
    // Check if transliterations exist (new field from quran-json library)
    final sample = await _isar.ayahs.where().findFirst();
    return sample?.transliteration != null;
  }

  /// Parses bundled JSON assets and inserts all Surahs + Ayahs into Isar.
  /// Clears existing data first to handle schema upgrades cleanly.
  Future<void> seed() async {
    final surahs = await QuranJsonParser.loadSurahs();
    final ayahs = await QuranJsonParser.loadAyahs();

    await _isar.writeTxn(() async {
      await _isar.surahs.clear();
      await _isar.ayahs.clear();
      await _isar.surahs.putAll(surahs);
      await _isar.ayahs.putAll(ayahs);
    });
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
      final file = await _positionFile();
      await file.writeAsString('$surahNumber:$ayahNumber');
    } catch (_) {}
  }

  /// Returns the last-read (surahNumber, ayahNumber). Defaults to (1, 1).
  Future<({int surah, int ayah})> getLastRead() async {
    try {
      final file = await _positionFile();
      if (!file.existsSync()) return (surah: 1, ayah: 1);
      final parts = file.readAsStringSync().trim().split(':');
      if (parts.length != 2) return (surah: 1, ayah: 1);
      return (surah: int.parse(parts[0]), ayah: int.parse(parts[1]));
    } catch (_) {
      return (surah: 1, ayah: 1);
    }
  }

  Future<File> _positionFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _positionFileName));
  }
}
