import 'dart:ffi';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';

bool _loaderConfigured = false;

/// Under `flutter test` there is no app executable with SQLite linked in (the
/// app gets it from sqlite3_flutter_libs), so the system library is used.
/// Many distros ship only the versioned `libsqlite3.so.0`, without the
/// unversioned `libsqlite3.so` dev symlink that package:sqlite3 looks for.
void _configureSqliteLoader() {
  if (_loaderConfigured) return;
  _loaderConfigured = true;
  open.overrideFor(OperatingSystem.linux, () {
    try {
      return DynamicLibrary.open('libsqlite3.so');
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return DynamicLibrary.open('libsqlite3.so.0');
    }
  });
}

/// A fresh in-memory [AppDatabase] for one test. Close it in a tearDown.
AppDatabase testDatabase() {
  _configureSqliteLoader();
  // Streams in tests are closed together with the database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
