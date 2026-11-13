import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Initializes and provides the singleton Isar database instance.
///
/// No collections remain (everything lives in SQLite now), and Isar refuses
/// to open with zero schemas, so [init] does nothing until a later task
/// removes Isar altogether.
class IsarService {
  IsarService._();

  static const List<CollectionSchema<dynamic>> _schemas = [];

  static Isar? _instance;

  static Isar get instance {
    assert(_instance != null, 'IsarService not initialized. Call init() first.');
    return _instance!;
  }

  /// Opens Isar if there are schemas to open; returns null otherwise.
  static Future<Isar?> init() async {
    if (_instance != null) return _instance;
    if (_schemas.isEmpty) return null;

    final dir = await getApplicationSupportDirectory();
    _instance = await Isar.open(
      _schemas,
      directory: dir.path,
      name: 'deen_audio',
    );
    return _instance;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
