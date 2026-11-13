import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/database/settings_repository.dart';
import 'package:deen_audio/core/providers/foundation_providers.dart';
import 'package:deen_audio/core/sync/auth_session.dart';
import 'package:deen_audio/features/library/data/library_scanner.dart';
import 'package:deen_audio/features/library/providers/library_providers.dart';
import 'package:deen_audio/features/settings/providers/settings_providers.dart';
import 'package:deen_audio/features/settings/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recording_settings_repository.dart';
import 'support/test_database.dart';

class _FakeScanner implements LibraryScanner {
  @override
  Future<String?> getLastFolder() async => '/home/u/HalalAudio';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _pumpSettings(WidgetTester tester, AppDatabase db,
    {Object? savedLocation, SettingsRepository? repo}) async {
  final container = ProviderContainer(overrides: [
    if (repo != null) settingsRepositoryProvider.overrideWithValue(repo),
    appDatabaseProvider.overrideWithValue(db),
    authSessionProvider
        .overrideWithValue(const LocalAuthSession(deviceId: 'device-1')),
    libraryScannerProvider.overrideWithValue(_FakeScanner()),
  ]);
  addTearDown(container.dispose);
  // Drift's queries run in the real zone, so seed and load the settings
  // there before the widgets first read them.
  await tester.runAsync(() async {
    if (savedLocation != null) {
      await container
          .read(settingsRepositoryProvider)
          .write('prayer.location', savedLocation);
    }
    await container.read(locationSettingsProvider.notifier).loaded;
    await container.read(quranFontSizeProvider.notifier).loaded;
  });
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
  ));
  await tester.pump();
  await tester.pump();
  return container;
}

String _fieldText(WidgetTester tester, String label) => tester
    .widget<TextField>(find.widgetWithText(TextField, label))
    .controller!
    .text;

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets(
      'shows the saved location when Settings is the first screen '
      'to read it', (tester) async {
    await _pumpSettings(tester, db, savedLocation: {
      'latitude': 21.3891,
      'longitude': 39.8579,
      'calculationMethod': 'ummAlQura',
    });

    expect(_fieldText(tester, 'Latitude'), '21.3891');
    expect(_fieldText(tester, 'Longitude'), '39.8579');
    expect(find.text('Umm al-Qura (Makkah)'), findsOneWidget);
  });

  testWidgets('rejects invalid coordinates and saves valid ones',
      (tester) async {
    // Saving writes in the fake-async zone, which a real database cannot
    // complete, so a recording fake stands in for the repository.
    final repo = RecordingSettingsRepository();
    final container = await _pumpSettings(tester, db, repo: repo);

    await tester.enterText(find.widgetWithText(TextField, 'Latitude'), '95');
    await tester.enterText(find.widgetWithText(TextField, 'Longitude'), '10');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Enter valid coordinates'), findsOneWidget);
    expect(container.read(locationSettingsProvider).hasLocation, isFalse);
    expect(repo.writes.where((w) => w.$1 == 'prayer.location'), isEmpty);

    await tester.enterText(
        find.widgetWithText(TextField, 'Latitude'), ' 51.50735 ');
    await tester.enterText(
        find.widgetWithText(TextField, 'Longitude'), '-0.12776');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Enter valid coordinates'), findsNothing);
    final loc = container.read(locationSettingsProvider);
    expect(loc.latitude, 51.50735);
    expect(loc.longitude, -0.12776);
    // What the user typed is not reformatted under their cursor.
    expect(_fieldText(tester, 'Longitude'), '-0.12776');

    final saved = repo.writes.where((w) => w.$1 == 'prayer.location').toList();
    expect(saved, hasLength(1));
    final json = saved.single.$2! as Map;
    expect(json['latitude'], 51.50735);
    expect(json['longitude'], -0.12776);
  });

  testWidgets('a corrupt saved method does not break the method dropdown',
      (tester) async {
    await _pumpSettings(tester, db, savedLocation: {
      'latitude': 1,
      'longitude': 2,
      'calculationMethod': 'bogus'
    });

    expect(tester.takeException(), isNull);
    expect(find.text('Muslim World League'), findsOneWidget);
  });

  testWidgets('the folder button changes the folder rather than "rescanning"',
      (tester) async {
    await _pumpSettings(tester, db);
    expect(find.text('HalalAudio'), findsOneWidget);
    expect(find.text('Change folder'), findsOneWidget);
  });

  testWidgets('does not overflow in a narrow content area', (tester) async {
    tester.view.physicalSize = const Size(420, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpSettings(tester, db);

    expect(tester.takeException(), isNull);
  });
}
