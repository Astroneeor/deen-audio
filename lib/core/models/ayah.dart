/// One ayah with its Arabic text and optional translation (bundled content;
/// stored in SQLite).
class Ayah {
  late int surahNumber;

  late int ayahNumber;

  late String arabicText;

  String? translation;
}
