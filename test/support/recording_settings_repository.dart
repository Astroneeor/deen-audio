import 'dart:async';

import 'package:deen_audio/core/database/settings_repository.dart';

/// An in-memory settings store that records every write, for widget tests
/// that must check what the UI saves without a real database.
class RecordingSettingsRepository implements SettingsRepository {
  /// Current values by key.
  final Map<String, Object?> values = {};

  /// Every write in order, as (key, value).
  final List<(String, Object?)> writes = [];

  @override
  Future<Object?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Object? jsonValue) async {
    writes.add((key, jsonValue));
    values[key] = jsonValue;
    _changes.add(key);
  }

  /// Emits the recorded value now, then every later write to [key].
  @override
  Stream<Object?> watch(String key) async* {
    yield values[key];
    yield* _changes.stream.where((k) => k == key).map((k) => values[k]);
  }

  final _changes = StreamController<String>.broadcast();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
