// The Quran translation on/off toggle persists in the settings table.
import 'dart:async';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/database/settings_repository.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/core/sync/sync_stamper.dart';
import 'package:deen_audio/features/quran/providers/quran_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_database.dart';

/// Holds every read until [gate] completes.
class _SlowRepo extends SettingsRepository {
  _SlowRepo(super.db, super.stamper);
  final gate = Completer<void>();

  @override
  Future<Object?> read(String key) async {
    await gate.future;
    return super.read(key);
  }
}

void main() {
  late AppDatabase db;
  late SyncStamper stamper;
  late SettingsRepository repo;
  var ids = 0;

  setUp(() {
    db = testDatabase();
    stamper = SyncStamper(
      session: const LocalAuthSession(deviceId: 'd'),
      now: () => DateTime.utc(2026, 11, 13),
      newId: () => 'id-${ids++}',
    );
    repo = SettingsRepository(db, stamper);
  });
  tearDown(() => db.close());

  test('defaults to on; a change is read back by a fresh notifier', () async {
    final n = ShowTranslationNotifier(repo);
    await n.loaded;
    expect(n.state, isTrue);

    await n.set(false);
    expect(await repo.read('quran.showTranslation'), false);

    final again = ShowTranslationNotifier(repo);
    await again.loaded;
    expect(again.state, isFalse);
  });

  test('a non-boolean saved value falls back to on', () async {
    for (final stored in <Object?>['false', 0, null, 1.5]) {
      await repo.write('quran.showTranslation', stored);
      final n = ShowTranslationNotifier(repo);
      await n.loaded;
      expect(n.state, isTrue, reason: 'stored $stored');
    }
  });

  test('a toggle made before the saved value loads is not overwritten',
      () async {
    await repo.write('quran.showTranslation', true);
    final slow = _SlowRepo(db, stamper);
    final n = ShowTranslationNotifier(slow);
    await n.set(false);
    slow.gate.complete();
    await n.loaded;
    expect(n.state, isFalse);
  });
}
