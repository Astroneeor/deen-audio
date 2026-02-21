import 'package:isar/isar.dart';

part 'ayah.g.dart';

@collection
class Ayah {
  Id id = Isar.autoIncrement;

  /// Composite index enables fast queries: "all ayahs of surah N, sorted by ayahNumber"
  @Index(composite: [CompositeIndex('ayahNumber')])
  late int surahNumber;

  late int ayahNumber;

  late String arabicText;

  String? translation;
}
