// Integrity checks for the bundled Quran dataset (assets/quran/*.json).
//
// These read the real asset files from disk; run with `flutter test` from
// the repo root. Expected ayah texts are derived from the data itself or
// from the translation, never typed in Arabic here.
import 'dart:io';

import 'package:deen_audio/core/models/ayah.dart';
import 'package:deen_audio/features/quran/data/quran_json_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuranData data;

  Ayah ayah(int surah, int number) => data.ayahs.singleWhere(
      (a) => a.surahNumber == surah && a.ayahNumber == number);

  setUpAll(() {
    data = QuranJsonParser.parse(
      File('assets/quran/quran_simple.json').readAsStringSync(),
      File('assets/quran/translation_en.json').readAsStringSync(),
    );
  });

  test('contains all 114 surahs numbered 1..114 with full metadata', () {
    expect(data.surahs.length, 114);
    expect(data.surahs.map((s) => s.number), List.generate(114, (i) => i + 1));
    for (final s in data.surahs) {
      expect(s.name.trim(), isNotEmpty, reason: 'surah ${s.number} name');
      expect(s.englishName.trim(), isNotEmpty);
      expect(s.englishNameTranslation.trim(), isNotEmpty);
      expect(s.revelationType, anyOf('Meccan', 'Medinan'));
    }
  });

  test('contains all 6236 ayahs', () {
    expect(data.ayahs.length, 6236);
  });

  test("each surah's ayahs are numbered 1..numberOfAyahs", () {
    final bySurah = <int, List<int>>{};
    for (final a in data.ayahs) {
      bySurah.putIfAbsent(a.surahNumber, () => []).add(a.ayahNumber);
    }
    for (final s in data.surahs) {
      expect(bySurah[s.number], List.generate(s.numberOfAyahs, (i) => i + 1),
          reason: 'surah ${s.number}');
    }
  });

  test('every ayah has non-empty Arabic text and translation', () {
    for (final a in data.ayahs) {
      final ref = '${a.surahNumber}:${a.ayahNumber}';
      expect(a.arabicText.trim(), isNotEmpty, reason: ref);
      expect(a.translation?.trim(), isNotEmpty, reason: ref);
      expect(a.arabicText, isNot(contains('﻿')), reason: '$ref BOM');
    }
  });

  test('Al-Fatiha 1:1 and An-Nas 114:6 are present', () {
    expect(data.surahs.first.englishName, 'Al-Faatiha');
    expect(data.surahs.first.numberOfAyahs, 7);
    expect(ayah(1, 1).translation,
        'In the name of Allah, the Entirely Merciful, the Especially Merciful.');

    expect(data.surahs.last.englishName, 'An-Naas');
    expect(data.surahs.last.numberOfAyahs, 6);
    expect(ayah(114, 6).arabicText.trim(), isNotEmpty);
    expect(ayah(114, 6).translation, 'From among the jinn and mankind."');
    expect(data.ayahs.last.surahNumber, 114);
    expect(data.ayahs.last.ayahNumber, 6);
  });

  test('basmala is left exactly as Tanzil ships it', () {
    final basmala = ayah(1, 1).arabicText;
    // At-Tawba has no basmala.
    expect(ayah(9, 1).arabicText.startsWith(basmala), isFalse);
    // Tanzil prefixes it to ayah 1 of the other surahs (95 and 97 carry a
    // variant spelling, so they are not an exact match).
    final prefixed = data.surahs
        .where((s) => s.number != 1)
        .where((s) => ayah(s.number, 1).arabicText.startsWith('$basmala '))
        .length;
    expect(prefixed, 110);
  });
}
