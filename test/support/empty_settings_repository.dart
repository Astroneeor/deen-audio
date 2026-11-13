import 'package:deen_audio/core/database/settings_repository.dart';

/// A settings store with nothing saved; writes are discarded. For tests that
/// need the settings providers to resolve without a database.
class EmptySettingsRepository implements SettingsRepository {
  @override
  Future<Object?> read(String key) async => null;

  @override
  Future<void> write(String key, Object? jsonValue) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
