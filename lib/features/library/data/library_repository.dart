import 'package:isar/isar.dart';

import '../../../core/models/track.dart';

/// All Isar CRUD for [Track].
/// Features read from this; nothing writes directly to Isar outside this class.
class LibraryRepository {
  final Isar _isar;

  const LibraryRepository(this._isar);

  // ── Reads ─────────────────────────────────────────────────────────────────

  /// Returns all tracks, sorted by type → title in Dart
  /// (avoids needing a composite Isar index).
  Future<List<Track>> getAllTracks() async {
    final list = await _isar.tracks.where().findAll();
    _sortInPlace(list);
    return list;
  }

  /// Live stream that fires immediately and on every DB change.
  Stream<List<Track>> watchAllTracks() {
    return _isar.tracks
        .where()
        .watch(fireImmediately: true)
        .map((list) => list..sort(_compareTrack));
  }

  Future<int> count() => _isar.tracks.count();

  /// Returns all Quran tracks (full-surah and per-ayah) for a given surah,
  /// specified as a zero-padded 3-digit string (e.g. "001", "114").
  Future<List<Track>> getQuranTracksBySurah(String surahNumber) async {
    final all = await _isar.tracks.where().findAll();
    return all
        .where(
          (t) => t.type == TrackType.quran && t.surahNumber == surahNumber,
        )
        .toList();
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Atomically clears the collection and inserts the new scan result.
  Future<void> replaceAllTracks(List<Track> tracks) async {
    await _isar.writeTxn(() async {
      await _isar.tracks.clear();
      await _isar.tracks.putAll(tracks);
    });
  }

  /// Persists changes to a single track (favorite toggle, lastPlayed, etc.).
  Future<void> updateTrack(Track track) async {
    await _isar.writeTxn(() => _isar.tracks.put(track));
  }

  /// Flips [Track.isFavorite] and saves.
  Future<void> toggleFavorite(Track track) async {
    track.isFavorite = !track.isFavorite;
    await updateTrack(track);
  }

  /// Records that this track was just played.
  Future<void> markPlayed(Track track) async {
    track.lastPlayed = DateTime.now();
    await updateTrack(track);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _sortInPlace(List<Track> list) => list.sort(_compareTrack);

  int _compareTrack(Track a, Track b) {
    final t = a.type.index.compareTo(b.type.index);
    return t != 0 ? t : a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
}
