import 'dart:io';

import 'package:deen_audio/features/library/data/library_scanner.dart';
import 'package:deen_audio/features/library/providers/library_providers.dart';
import 'package:deen_audio/features/settings/providers/settings_providers.dart';
import 'package:deen_audio/features/settings/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/fake_path_provider.dart';

class _FakeScanner implements LibraryScanner {
  @override
  Future<String?> getLastFolder() async => '/home/u/HalalAudio';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _pumpSettings(WidgetTester tester) async {
  final container = ProviderContainer(overrides: [
    libraryScannerProvider.overrideWithValue(_FakeScanner()),
  ]);
  addTearDown(container.dispose);
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
  late Directory dir;
  setUp(() => dir = useTempAppSupportDir());

  testWidgets('shows the saved location when Settings is the first screen '
      'to read it', (tester) async {
    File(p.join(dir.path, 'prayer_location.json')).writeAsStringSync(
        '{"latitude":21.3891,"longitude":39.8579,"calculationMethod":"ummAlQura"}');

    await _pumpSettings(tester);

    expect(_fieldText(tester, 'Latitude'), '21.3891');
    expect(_fieldText(tester, 'Longitude'), '39.8579');
    expect(find.text('Umm al-Qura (Makkah)'), findsOneWidget);
  });

  testWidgets('rejects invalid coordinates and saves valid ones',
      (tester) async {
    final container = await _pumpSettings(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Latitude'), '95');
    await tester.enterText(find.widgetWithText(TextField, 'Longitude'), '10');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Enter valid coordinates'), findsOneWidget);
    expect(container.read(locationSettingsProvider).hasLocation, isFalse);

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
  });

  testWidgets('a corrupt saved method does not break the method dropdown',
      (tester) async {
    File(p.join(dir.path, 'prayer_location.json')).writeAsStringSync(
        '{"latitude":1,"longitude":2,"calculationMethod":"bogus"}');

    await _pumpSettings(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Muslim World League'), findsOneWidget);
  });

  testWidgets('the folder button changes the folder rather than "rescanning"',
      (tester) async {
    await _pumpSettings(tester);
    expect(find.text('HalalAudio'), findsOneWidget);
    expect(find.text('Change folder'), findsOneWidget);
  });

  testWidgets('does not overflow in a narrow content area', (tester) async {
    tester.view.physicalSize = const Size(420, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpSettings(tester);

    expect(tester.takeException(), isNull);
  });
}
