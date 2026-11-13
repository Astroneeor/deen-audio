import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/core/sync/sync_stamper.dart';
import 'package:deen_audio/features/library/data/library_repository.dart';

import 'memory_file_store.dart';
import 'test_database.dart';

/// Library root used by [LibraryRepoHarness.scan].
const libRoot = '/m';

/// A scanned track at [path] (title = file name).
Track libTrack(String path, {TrackType type = TrackType.nasheed}) => Track()
  ..title = path.split('/').last
  ..type = type
  ..filePath = path;

/// Shared setup for the LibraryRepository tests: an in-memory database, a
/// memory file store rooted at `/store`, and a stamper whose clock is [now].
/// Wire it with `setUp(h.setUp); tearDown(h.tearDown);`.
class LibraryRepoHarness {
  late AppDatabase db;
  late MemoryFileStore files;
  late LibraryRepository repo;
  late DateTime now;
  var _ids = 0;

  void setUp() {
    db = testDatabase();
    files = MemoryFileStore(base: '/store');
    now = DateTime.utc(2026, 11, 13, 9);
    final stamper = SyncStamper(
      session: const LocalAuthSession(deviceId: 'device-1'),
      now: () => now,
      newId: () => 'id-${_ids++}',
    );
    repo = LibraryRepository(db, stamper, files);
  }

  Future<void> tearDown() => db.close();

  /// Replaces the scanned tracks under [libRoot].
  Future<void> scan(List<Track> tracks, {List<String> keepUnder = const []}) =>
      repo.replaceAllTracks(tracks, libraryRoot: libRoot, keepUnder: keepUnder);

  /// The stored track with [path].
  Future<Track> byPath(String path) async =>
      (await repo.getAllTracks()).firstWhere((t) => t.filePath == path);
}
