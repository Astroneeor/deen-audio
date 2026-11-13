import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/models/track.dart';
import '../../../core/storage/file_store.dart';
import '../../../core/sync/sync_stamper.dart';

/// Reads and writes the audio library in the SQLite [AppDatabase].
///
/// Tracks are device-local (`tracks`); favourite and last-played are user
/// data (`track_states`, keyed by track key) so they survive rescans and can
/// sync. Both are joined into [Track] on read.
class LibraryRepository {
  LibraryRepository(this._db, this._stamper, this._files);

  final AppDatabase _db;
  final SyncStamper _stamper;
  final FileStore _files;

  // ── Reads ─────────────────────────────────────────────────────────────────

  /// All tracks, sorted by type → title.
  Future<List<Track>> getAllTracks() async => _toTracks(await _joined().get());

  /// Live list: emits now and after every change to tracks or their state.
  Stream<List<Track>> watchAllTracks() =>
      _joined().watch().asyncMap(_toTracks);

  Future<int> count() async {
    final n = countAll();
    final row = await (_db.selectOnly(_db.tracks)..addColumns([n])).getSingle();
    return row.read(n)!;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _joined() =>
      _db.select(_db.tracks).join([
        leftOuterJoin(
          _db.trackStates,
          _db.trackStates.trackKey.equalsExp(_db.tracks.trackKey) &
              _db.trackStates.deletedAt.isNull(),
        ),
      ]);

  Future<List<Track>> _toTracks(List<TypedResult> rows) async {
    final tracks = <Track>[];
    for (final r in rows) {
      final t = r.readTable(_db.tracks);
      final s = r.readTableOrNull(_db.trackStates);
      final downloaded = t.source == TrackSourceKind.downloaded.name;
      tracks.add(Track()
        ..id = t.id
        ..title = t.title
        ..artist = t.artist
        ..type = TrackType.values.byName(t.type)
        ..filePath = downloaded ? await _files.absolute(t.filePath) : t.filePath
        ..duration = t.durationMs
        ..surahNumber = t.surahNumber
        ..trackKey = t.trackKey
        ..source = TrackSourceKind.values.byName(t.source)
        ..isFavorite = s?.isFavorite ?? false
        ..lastPlayed = s?.lastPlayed);
    }
    return tracks..sort(_compare);
  }

  int _compare(Track a, Track b) {
    final t = a.type.index.compareTo(b.type.index);
    return t != 0 ? t : a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  // ── Scanned tracks ────────────────────────────────────────────────────────

  /// `lib:<path relative to the library folder>`, always with `/`.
  static String libraryKey(String filePath, String libraryRoot) =>
      'lib:${p.posix.joinAll(p.split(p.relative(filePath, from: libraryRoot)))}';

  /// Makes the scanned part of the library match a fresh scan, in one
  /// transaction. Downloaded tracks and all `track_states` are untouched.
  ///
  /// A file that was already known (same key) keeps its id and measured
  /// duration while title / artist / type are refreshed. Files no longer on
  /// disk are removed, except those under one of the [keepUnder] directories:
  /// folders the scanner could not read, whose contents are unknown.
  Future<void> replaceAllTracks(
    List<Track> scanned, {
    required String libraryRoot,
    Iterable<String> keepUnder = const [],
  }) =>
      _db.transaction(() async {
        final old = {
          for (final r in await (_db.select(_db.tracks)
                ..where((t) => t.source.equals(TrackSourceKind.scanned.name)))
              .get())
            r.trackKey: r,
        };
        final fresh = {
          for (final t in scanned) libraryKey(t.filePath, libraryRoot): t,
        };

        for (final e in fresh.entries) {
          final t = e.value;
          final prev = old.remove(e.key);
          if (prev == null) {
            await _db.into(_db.tracks).insert(TracksCompanion.insert(
                  title: t.title,
                  artist: Value(t.artist),
                  type: t.type.name,
                  filePath: t.filePath,
                  durationMs: Value(t.duration),
                  surahNumber: Value(t.surahNumber),
                  trackKey: e.key,
                  source: TrackSourceKind.scanned.name,
                ));
          } else {
            await (_db.update(_db.tracks)..where((r) => r.id.equals(prev.id)))
                .write(TracksCompanion(
              title: Value(t.title),
              artist: Value(t.artist),
              type: Value(t.type.name),
              filePath: Value(t.filePath),
              durationMs: Value(t.duration == 0 ? prev.durationMs : t.duration),
              surahNumber: Value(t.surahNumber ?? prev.surahNumber),
            ));
          }
        }

        // What is left in `old` was not seen by this scan.
        final gone = [
          for (final r in old.values)
            if (!keepUnder.any((dir) => p.isWithin(dir, r.filePath))) r.id,
        ];
        await (_db.delete(_db.tracks)..where((r) => r.id.isIn(gone))).go();
      });

  // ── Downloaded tracks ─────────────────────────────────────────────────────

  /// Adds (or refreshes) the track for a completed download.
  Future<void> upsertDownloadedTrack({
    required String catalogFileId,
    required String title,
    required String artist,
    required TrackType type,
    required String relativePath,
    String? surahNumber,
  }) =>
      _db.into(_db.tracks).insert(
            TracksCompanion.insert(
              title: title,
              artist: Value(artist),
              type: type.name,
              filePath: relativePath,
              surahNumber: Value(surahNumber),
              trackKey: 'dl:$catalogFileId',
              source: TrackSourceKind.downloaded.name,
            ),
            onConflict: DoUpdate(
              (_) => TracksCompanion(
                title: Value(title),
                artist: Value(artist),
                type: Value(type.name),
                filePath: Value(relativePath),
                surahNumber: Value(surahNumber),
              ),
              target: [_db.tracks.trackKey],
            ),
          );

  /// Removes the track of a deleted download. Its favourite/last-played state
  /// is kept, so a re-download restores it.
  Future<void> removeDownloadedTrack(String catalogFileId) => (_db
          .delete(_db.tracks)
        ..where((t) => t.trackKey.equals('dl:$catalogFileId')))
      .go();

  // ── User state ────────────────────────────────────────────────────────────

  /// Records a measured duration (ms) for [track].
  Future<void> updateDuration(Track track, int milliseconds) =>
      (_db.update(_db.tracks)..where((t) => t.id.equals(track.id)))
          .write(TracksCompanion(durationMs: Value(milliseconds)));

  /// Flips the stored favourite flag of [track] (in `track_states`).
  ///
  /// The current value is read inside the write transaction, so a stale
  /// [track] cannot cause a wrong write. Throws [ArgumentError] if [track]
  /// was never stored (empty trackKey).
  Future<void> toggleFavorite(Track track) async {
    _requireKey(track);
    track.isFavorite = await _writeState(track.trackKey,
        isFavorite: (e) => !(e?.isFavorite ?? false)) as bool;
  }

  /// Records that [track] was just played. Throws [ArgumentError] if [track]
  /// was never stored (empty trackKey).
  Future<void> markPlayed(Track track) async {
    _requireKey(track);
    final at = _stamper.nowUtc();
    await _writeState(track.trackKey, lastPlayed: at);
    track.lastPlayed = at;
  }

  void _requireKey(Track track) {
    if (track.trackKey.isEmpty) {
      throw ArgumentError.value(track.title, 'track', 'has no trackKey');
    }
  }

  /// Creates or updates (reviving if soft-deleted) the state row of [key].
  ///
  /// [isFavorite] computes the new flag from the stored row (null if none or
  /// a tombstone, whose old state is dropped: revival starts from defaults);
  /// its result is returned, or null when not given.
  Future<bool?> _writeState(
    String key, {
    bool Function(TrackStateRow? existing)? isFavorite,
    DateTime? lastPlayed,
  }) =>
      _db.transaction(() async {
        final existing = await (_db.select(_db.trackStates)
              ..where((t) => t.trackKey.equals(key)))
            .getSingleOrNull();
        final revive = existing != null && existing.deletedAt != null;
        final favourite = isFavorite?.call(revive ? null : existing);
        final stamp = TrackStatesCompanion(
          isFavorite: favourite != null
              ? Value(favourite)
              : revive ? const Value(false) : const Value.absent(),
          lastPlayed: lastPlayed != null
              ? Value(lastPlayed)
              : revive ? const Value(null) : const Value.absent(),
          updatedAt: Value(_stamper.nowUtc()),
          deletedAt: const Value(null),
          deviceId: Value(_stamper.deviceId),
          userId: Value(_stamper.userId),
        );
        if (existing == null) {
          await _db.into(_db.trackStates).insert(stamp.copyWith(
                id: Value(_stamper.newId()),
                trackKey: Value(key),
              ));
        } else {
          await (_db.update(_db.trackStates)
                ..where((t) => t.id.equals(existing.id)))
              .write(stamp);
        }
        return favourite;
      });
}
