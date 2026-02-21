import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/models/ayah.dart';
import '../../../core/models/surah.dart';

/// Parses Tanzil-compatible JSON assets into Isar model lists.
///
/// Expected quran_simple.json format — array of surah objects:
/// [{"number":1,"name":"الفاتحة","englishName":"Al-Faatiha",
///   "englishNameTranslation":"The Opening","numberOfAyahs":7,
///   "revelationType":"Meccan","ayahs":[{"number":1,"text":"..."}]}]
///
/// Expected translation_en.json format — array matching surah numbers:
/// [{"number":1,"ayahs":[{"number":1,"text":"..."}]}]
class QuranJsonParser {
  static const _quranAsset = 'assets/quran/quran_simple.json';
  static const _translationAsset = 'assets/quran/translation_en.json';

  /// Loads both asset files and returns parsed [Surah] list.
  static Future<List<Surah>> loadSurahs() async {
    final raw = await rootBundle.loadString(_quranAsset);
    return _parseSurahs(raw);
  }

  /// Loads both asset files and returns parsed [Ayah] list with translations.
  static Future<List<Ayah>> loadAyahs() async {
    final quranRaw = await rootBundle.loadString(_quranAsset);
    final transRaw = await rootBundle.loadString(_translationAsset);
    return _parseAyahs(quranRaw, transRaw);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static List<Surah> _parseSurahs(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((s) {
      final m = s as Map<String, dynamic>;
      return Surah()
        ..number = m['number'] as int
        ..name = m['name'] as String
        ..englishName = m['englishName'] as String
        ..englishNameTranslation = m['englishNameTranslation'] as String
        ..numberOfAyahs = m['numberOfAyahs'] as int
        ..revelationType = m['revelationType'] as String;
    }).toList();
  }

  static List<Ayah> _parseAyahs(String quranJson, String transJson) {
    final quranList = jsonDecode(quranJson) as List<dynamic>;
    final transList = jsonDecode(transJson) as List<dynamic>;

    // Build translation lookup: surahNumber → {ayahNumber → text}
    final transLookup = <int, Map<int, String>>{};
    for (final s in transList) {
      final m = s as Map<String, dynamic>;
      final surahNum = m['number'] as int;
      final ayahMap = <int, String>{};
      for (final a in (m['ayahs'] as List<dynamic>)) {
        final am = a as Map<String, dynamic>;
        ayahMap[am['number'] as int] = am['text'] as String;
      }
      transLookup[surahNum] = ayahMap;
    }

    final ayahs = <Ayah>[];
    for (final s in quranList) {
      final m = s as Map<String, dynamic>;
      final surahNum = m['number'] as int;
      final ayahList = (m['ayahs'] as List<dynamic>?) ?? [];
      for (final a in ayahList) {
        final am = a as Map<String, dynamic>;
        final ayahNum = am['number'] as int;
        ayahs.add(Ayah()
          ..surahNumber = surahNum
          ..ayahNumber = ayahNum
          ..arabicText = am['text'] as String
          ..translation = transLookup[surahNum]?[ayahNum]);
      }
    }
    return ayahs;
  }
}
