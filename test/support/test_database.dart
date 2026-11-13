import 'package:deen_audio/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// A fresh in-memory [AppDatabase] for one test. Close it in a tearDown.
///
/// SQLite comes from package:sqlite3's build hook, which `flutter test` runs
/// like a real build: it provides the same prebuilt library the app bundles,
/// so tests need no system SQLite and no loader override.
AppDatabase testDatabase() {
  // Streams in tests are closed together with the database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
