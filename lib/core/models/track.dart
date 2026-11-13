enum TrackType { quran, adhkar, nasheed, whiteNoise }

/// Where a track came from: a library-folder scan or a catalog download.
enum TrackSourceKind { scanned, downloaded }

/// A playable audio file. Plain value object: the repository builds it from
/// the `tracks` table joined with the user's `track_states`.
class Track {
  /// Local row id (0 for a track that was never stored).
  int id = 0;

  late String title;

  /// Reciter name for Quran, artist name for nasheeds
  String? artist;

  late TrackType type;

  /// Always an absolute path once the track has left the repository.
  late String filePath;

  /// Duration in milliseconds
  int duration = 0;

  bool isFavorite = false;

  /// UTC time of the last playback.
  DateTime? lastPlayed;

  /// Only populated for Quran tracks
  String? surahNumber;

  /// `lib:<path relative to the library folder>` or `dl:<catalog file id>`.
  /// Empty until the repository stores the track.
  String trackKey = '';

  TrackSourceKind source = TrackSourceKind.scanned;
}
