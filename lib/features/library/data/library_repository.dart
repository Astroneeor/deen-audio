import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

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

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Makes the collection match a fresh scan result, in one transaction.
  ///
  /// Tracks are matched by [Track.filePath]. A file that was already in the
  /// library keeps its id (playlists reference ids) and its per-track user
  /// state — favourite flag, last-played time and measured duration — while
  /// title / artist / type are refreshed from the scan. Files that are no
  /// longer on disk are removed, except those under one of the [keepUnder]
  /// directories: folders the scanner could not read, whose contents are
  /// unknown rather than gone.
  Future<void> replaceAllTracks(
    List<Track> tracks, {
    Iterable<String> keepUnder = const [],
  }) async {
    await _isar.writeTxn(() async {
      final existingByPath = <String, Track>{};
      final staleIds = <Id>[];
      for (final old in await _isar.tracks.where().findAll()) {
        if (existingByPath.containsKey(old.filePath)) {
          staleIds.add(old.id); // duplicate row for the same file
        } else {
          existingByPath[old.filePath] = old;
        }
      }

      final scannedByPath = {for (final t in tracks) t.filePath: t};
      for (final scanned in scannedByPath.values) {
        final old = existingByPath.remove(scanned.filePath);
        if (old == null) continue;
        scanned
          ..id = old.id
          ..isFavorite = old.isFavorite
          ..lastPlayed = old.lastPlayed
          ..surahNumber ??= old.surahNumber;
        if (scanned.duration == 0) scanned.duration = old.duration;
      }

      // Whatever is left in existingByPath was not seen by this scan.
      for (final old in existingByPath.values) {
        final unknown = keepUnder.any((dir) => p.isWithin(dir, old.filePath));
        if (!unknown) staleIds.add(old.id);
      }

      await _isar.tracks.deleteAll(staleIds);
      await _isar.tracks.putAll(scannedByPath.values.toList());
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
