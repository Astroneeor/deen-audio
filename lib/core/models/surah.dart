import 'package:isar/isar.dart';

part 'surah.g.dart';

@collection
class Surah {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int number; // 1 – 114

  late String name; // Arabic: "الفاتحة"

  late String englishName; // "Al-Faatiha"

  late String englishNameTranslation; // "The Opening"

  late int numberOfAyahs;

  late String revelationType; // "Meccan" | "Medinan"
}
