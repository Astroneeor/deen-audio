import 'package:deen_audio/core/theme/app_fonts.dart';
import 'package:deen_audio/features/adhkar/data/adhkar_repository.dart';
import 'package:deen_audio/features/adhkar/providers/adhkar_providers.dart';
import 'package:deen_audio/features/adhkar/ui/adhkar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _dhikr = Dhikr(
  id: 1,
  title: 'Sample',
  arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
  transliteration: 'SubhanAllahi wa bihamdih.',
  translation: 'Sample translation',
  count: 100,
  reference: 'Sample reference',
);

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      morningAdhkarProvider.overrideWith((ref) => [_dhikr]),
      eveningAdhkarProvider.overrideWith((ref) => <Dhikr>[]),
    ],
    child: const MaterialApp(home: Scaffold(body: AdhkarScreen())),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders a dhikr card with RTL Arabic in the Quran font',
      (tester) async {
    await _pump(tester);

    final arabic = tester.widget<Text>(find.text(_dhikr.arabic));
    expect(arabic.style?.fontFamily, AppFonts.quranText);
    expect(Directionality.of(tester.element(find.text(_dhikr.arabic))),
        TextDirection.rtl);
    expect(find.text('×100'), findsOneWidget);
    expect(find.text('Sample reference'), findsOneWidget);
  });

  testWidgets('evening tab shows its own (empty) state', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();
    expect(find.text('No adhkar found'), findsOneWidget);
  });

  testWidgets('fits a small window', (tester) async {
    tester.view.physicalSize = const Size(420, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
