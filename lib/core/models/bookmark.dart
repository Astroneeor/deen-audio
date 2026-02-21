import 'package:isar/isar.dart';

part 'bookmark.g.dart';

@collection
class Bookmark {
  Id id = Isar.autoIncrement;

  late int surahNumber;

  late int ayahNumber;

  DateTime savedAt = DateTime.now();
}
