import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File name of the database inside the app-support directory.
const databaseFileName = 'deen_audio.sqlite';

/// Opens `deen_audio.sqlite` in the app-support directory on a background
/// isolate, so queries never block the UI thread.
///
/// SQLite itself comes from sqlite3_flutter_libs, which links it into desktop
/// builds; package:sqlite3 finds it there automatically.
///
/// This is the single connection factory: a web implementation would be added
/// beside it (conditional import), not in callers.
QueryExecutor openNativeConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, databaseFileName));
    return NativeDatabase.createInBackground(file);
  });
}
