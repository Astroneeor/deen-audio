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
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
