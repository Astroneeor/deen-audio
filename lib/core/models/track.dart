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

  /// True if this file is a per-ayah MP3 in EveryAyah SSSAAA.mp3 format.
  bool isAyahFile = false;

  /// Ayah number within the surah. Only set when [isAyahFile] is true.
  int? ayahNumber;
}
