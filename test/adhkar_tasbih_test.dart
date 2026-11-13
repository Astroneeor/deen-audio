import 'package:deen_audio/features/adhkar/ui/tasbih_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showTasbihCounter(context),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Taps the big count area [times] times.
Future<void> _count(WidgetTester tester, int times) async {
  for (var i = 0; i < times; i++) {
    await tester.tapAt(const Offset(400, 200));
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('counts to the default target of 33 and then stops',
      (tester) async {
    await _open(tester);

    await _count(tester, 32);
    expect(find.text('32'), findsOneWidget);
    expect(find.textContaining('Complete'), findsNothing);

    await _count(tester, 1);
    expect(find.textContaining('Complete'), findsOneWidget);

    await _count(tester, 5);
    expect(find.text('33'), findsNWidgets(2), // the count and the 33 chip
        reason: 'taps after completion must not count');
  });

  testWidgets('reset starts over; choosing a target restarts the count',
      (tester) async {
    await _open(tester);
    await _count(tester, 33);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(find.textContaining('Complete'), findsNothing);

    await _count(tester, 10);
    await tester.tap(find.text('99'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    await _count(tester, 40);
    expect(find.text('40'), findsOneWidget);
    expect(find.textContaining('Complete'), findsNothing);
  });

  testWidgets('the ∞ target never completes', (tester) async {
    await _open(tester);
    await tester.tap(find.text('∞'));
    await tester.pumpAndSettle();

    await _count(tester, 1001);

    expect(find.text('1001'), findsOneWidget);
    expect(find.textContaining('Complete'), findsNothing);
  });

  testWidgets('does not overflow in a short window', (tester) async {
    tester.view.physicalSize = const Size(640, 330);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _open(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('close button dismisses the counter', (tester) async {
    await _open(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Reset'), findsNothing);
  });
}
