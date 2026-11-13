import 'package:drift/drift.dart';

// Bundled content: read-only, re-seedable from the JSON assets, never synced.

/// The 114 surahs.
@DataClassName('SurahRow')
class Surahs extends Table {
  IntColumn get number => integer()();
  TextColumn get name => text()();
  TextColumn get englishName => text()();
  TextColumn get englishNameTranslation => text()();
  IntColumn get numberOfAyahs => integer()();
  TextColumn get revelationType => text()();

  @override
  Set<Column> get primaryKey => {number};
}

/// Every ayah with its Arabic text and (optional) translation.
@DataClassName('AyahRow')
class Ayahs extends Table {
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get arabicText => text()();
  TextColumn get translation => text().nullable()();

  @override
  Set<Column> get primaryKey => {surahNumber, ayahNumber};
}
