import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/models/ayah.dart';
import '../../../core/models/surah.dart';

/// Parses quran-json library assets into Isar model lists.
///
/// Expected quran.json format — array of surah objects:
/// [{"id":1,"name":"الفاتحة","transliteration":"Al-Fatihah",
///   "type":"meccan","total_verses":7,
///   "verses":[{"id":1,"text":"..."}]}]
///
/// Expected quran_en.json — same structure with added "translation" fields:
/// [{"id":1,...,"translation":"The Opener",
///   "verses":[{"id":1,"text":"...","translation":"..."}]}]
///
/// Expected quran_transliteration.json — same with "transliteration" on verses:
/// [{"id":1,...,"verses":[{"id":1,"text":"...","transliteration":"..."}]}]
class QuranJsonParser {
  static const _quranAsset = 'assets/quran/quran.json';
  static const _translationAsset = 'assets/quran/quran_en.json';
  static const _transliterationAsset =
      'assets/quran/quran_transliteration.json';

  /// Loads quran_en.json (has both Arabic text and English translations on
  /// surahs) and returns parsed [Surah] list.
  static Future<List<Surah>> loadSurahs() async {
    final raw = await rootBundle.loadString(_translationAsset);
    return _parseSurahs(raw);
  }

  /// Loads Arabic text, English translations, and transliterations, then
  /// returns a merged [Ayah] list.
  static Future<List<Ayah>> loadAyahs() async {
    final quranRaw = await rootBundle.loadString(_quranAsset);
    final transRaw = await rootBundle.loadString(_translationAsset);
    final translitRaw = await rootBundle.loadString(_transliterationAsset);
    return _parseAyahs(quranRaw, transRaw, translitRaw);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static List<Surah> _parseSurahs(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((s) {
      final m = s as Map<String, dynamic>;
      return Surah()
        ..number = m['id'] as int
        ..name = m['name'] as String
        ..englishName = m['transliteration'] as String
        ..englishNameTranslation = (m['translation'] as String?) ?? ''
        ..numberOfAyahs = m['total_verses'] as int
        ..revelationType = _capitalise(m['type'] as String);
    }).toList();
  }

  static List<Ayah> _parseAyahs(
    String quranJson,
    String transJson,
    String translitJson,
  ) {
    final quranList = jsonDecode(quranJson) as List<dynamic>;
    final transList = jsonDecode(transJson) as List<dynamic>;
    final translitList = jsonDecode(translitJson) as List<dynamic>;

    // Build translation lookup: surahId → {verseId → text}
    final transLookup = <int, Map<int, String>>{};
    for (final s in transList) {
      final m = s as Map<String, dynamic>;
      final surahId = m['id'] as int;
      final verseMap = <int, String>{};
      for (final v in (m['verses'] as List<dynamic>)) {
        final vm = v as Map<String, dynamic>;
        verseMap[vm['id'] as int] = vm['translation'] as String;
      }
      transLookup[surahId] = verseMap;
    }

    // Build transliteration lookup: surahId → {verseId → text}
    final translitLookup = <int, Map<int, String>>{};
    for (final s in translitList) {
      final m = s as Map<String, dynamic>;
      final surahId = m['id'] as int;
      final verseMap = <int, String>{};
      for (final v in (m['verses'] as List<dynamic>)) {
        final vm = v as Map<String, dynamic>;
        final tl = vm['transliteration'] as String?;
        if (tl != null) verseMap[vm['id'] as int] = tl;
      }
      translitLookup[surahId] = verseMap;
    }

    final ayahs = <Ayah>[];
    for (final s in quranList) {
      final m = s as Map<String, dynamic>;
      final surahId = m['id'] as int;
      final verseList = (m['verses'] as List<dynamic>?) ?? [];
      for (final v in verseList) {
        final vm = v as Map<String, dynamic>;
        final verseId = vm['id'] as int;
        ayahs.add(Ayah()
          ..surahNumber = surahId
          ..ayahNumber = verseId
          ..arabicText = vm['text'] as String
          ..translation = transLookup[surahId]?[verseId]
          ..transliteration = translitLookup[surahId]?[verseId]);
      }
    }
    return ayahs;
  }

  /// "meccan" → "Meccan", "medinan" → "Medinan"
  static String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
