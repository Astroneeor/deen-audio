import 'package:isar/isar.dart';

part 'track.g.dart';

enum TrackType { quran, adhkar, nasheed, whiteNoise }

@collection
class Track {
  Id id = Isar.autoIncrement;

  late String title;

  /// Reciter name for Quran, artist name for nasheeds
  String? artist;

  @enumerated
  late TrackType type;

  /// Local file path today; URL later via TrackSource abstraction
  late String filePath;

  /// Duration in milliseconds
  int duration = 0;

  bool isFavorite = false;

  DateTime? lastPlayed;

  /// Only populated for Quran tracks
  String? surahNumber;
}
