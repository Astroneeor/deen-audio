import '../../../core/models/track.dart';

/// Library display (and play-queue) order: by type, then
/// - Quran tracks by reciter, then numeric surah number (missing last),
///   then title, so a queue plays 1, 2, … 114 of one reciter;
/// - all other types by title.
int compareTracks(Track a, Track b) {
  final type = a.type.index.compareTo(b.type.index);
  if (type != 0) return type;
  if (a.type == TrackType.quran) {
    final artist = _lower(a.artist).compareTo(_lower(b.artist));
    if (artist != 0) return artist;
    final surah = _compareSurah(a.surahNumber, b.surahNumber);
    if (surah != 0) return surah;
  }
  return _lower(a.title).compareTo(_lower(b.title));
}

String _lower(String? s) => (s ?? '').toLowerCase();

int _compareSurah(String? a, String? b) {
  final x = a == null ? null : int.tryParse(a);
  final y = b == null ? null : int.tryParse(b);
  if (x == null || y == null) {
    return x == y ? 0 : (x == null ? 1 : -1);
  }
  return x.compareTo(y);
}
