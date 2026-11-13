import 'dart:convert';
import 'dart:io';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:drift/drift.dart' show HasResultSet, ResultSetImplementation;
import 'package:deen_audio/core/database/device_settings_repository.dart';
import 'package:deen_audio/core/database/settings_repository.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/core/sync/sync_stamper.dart';
import 'package:deen_audio/features/quran/data/quran_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SettingsRepository settings;
  late QuranRepository repo;
  var ids = 0;

  setUp(() {
    db = testDatabase();
    final stamper = SyncStamper(
      session: const LocalAuthSession(deviceId: 'device-1'),
      now: () => DateTime.utc(2026, 11, 13, 9),
      newId: () => 'id-${ids++}',
    );
    settings = SettingsRepository(db, stamper);
    repo = QuranRepository(db, stamper, settings, DeviceSettingsRepository(db));
  });
  tearDown(() => db.close());

  Future<int> count<T extends HasResultSet, D>(
          ResultSetImplementation<T, D> t) async =>
      (await db.select(t).get()).length;

  test('seed stores 114 surahs and 6236 ayahs and marks seeded', () async {
    expect(await repo.isSeeded(), isFalse);
    await repo.seed();
    expect(await count(db.surahs), 114);
    expect(await count(db.ayahs), 6236);
    expect(await repo.isSeeded(), isTrue);
  });

  test('ayah text round-trips byte-identical to the assets', () async {
    await repo.seed();
    final quran =
        jsonDecode(File('assets/quran/quran_simple.json').readAsStringSync())
            as List;
    final trans =
        jsonDecode(File('assets/quran/translation_en.json').readAsStringSync())
            as List;
    expect(
        (await repo.getAyahs(1))[0].arabicText, quran[0]['ayahs'][0]['text']);
    expect((await repo.getAyahs(114))[5].arabicText,
        quran[113]['ayahs'][5]['text']);
    expect((await repo.getAyahs(114))[5].translation,
        trans[113]['ayahs'][5]['text']);
  });

  test('second seed leaves counts unchanged', () async {
    await repo.seed();
    await repo.seed();
    expect(await count(db.surahs), 114);
    expect(await count(db.ayahs), 6236);
  });

  test('toggling a bookmark three times leaves one live row, one row total',
      () async {
    await repo.toggleBookmark(2, 255);
    await repo.toggleBookmark(2, 255);
    await repo.toggleBookmark(2, 255);
    final live = await repo.watchBookmarks().first;
    expect(live, hasLength(1));
    expect(live.single.surahNumber, 2);
    expect(live.single.ayahNumber, 255);
    expect(await count(db.bookmarks), 1);
    expect(await repo.getBookmarkedAyahNumbers(2), {255});
  });

  test('watchBookmarks excludes soft-deleted rows', () async {
    await repo.toggleBookmark(2, 255);
    await repo.toggleBookmark(2, 255);
    expect(await repo.watchBookmarks().first, isEmpty);
    expect(await repo.getBookmarkedAyahNumbers(2), isEmpty);
    expect(await count(db.bookmarks), 1);
  });

  test('last-read round-trips', () async {
    await repo.seed();
    await repo.saveLastRead(2, 255);
    final pos = await repo.getLastRead();
    expect((pos!.surah, pos.ayah), (2, 255));
  });

  test('invalid stored last-read reads back as null', () async {
    await repo.seed();
    await settings.write('quran.lastRead', {'surah': 999, 'ayah': 1});
    expect(await repo.getLastRead(), isNull);
    await settings.write('quran.lastRead', {'surah': 1, 'ayah': 8});
    expect(await repo.getLastRead(), isNull);
  });
}
