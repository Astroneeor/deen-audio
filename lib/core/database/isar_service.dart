import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/bookmark.dart';
import '../models/playlist.dart';
import '../models/track.dart';

/// Initializes and provides the singleton Isar database instance.
class IsarService {
  IsarService._();

  static Isar? _instance;

  static Isar get instance {
    assert(_instance != null, 'IsarService not initialized. Call init() first.');
    return _instance!;
  }

  static Future<Isar> init() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationSupportDirectory();
    _instance = await Isar.open(
      [TrackSchema, PlaylistSchema, BookmarkSchema],
      directory: dir.path,
      name: 'deen_audio',
    );
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
