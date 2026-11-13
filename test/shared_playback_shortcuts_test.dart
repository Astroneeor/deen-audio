import 'package:deen_audio/shared/widgets/playback_shortcut_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the app shell: the scope sits inside the root navigator's page and
/// wraps a nested navigator (go_router's ShellRoute), so both root-level
/// dialogs and shell-level sheets are exercised.
Widget _app(
  List<PlaybackShortcut> fired, {
  VoidCallback? onButton,
  FocusNode? sliderFocus,
  ValueChanged<double>? onSlider,
}) {
  return MaterialApp(
    home: PlaybackShortcutScope(
      onShortcut: fired.add,
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                const TextField(key: Key('field')),
                TextButton(onPressed: onButton, child: const Text('button')),
                TextButton(
                  onPressed: () => showGeneralDialog<void>(
                    context: context,
                    pageBuilder: (ctx, _, __) => Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('close'),
                      ),
                    ),
                  ),
                  child: const Text('dialog'),
                ),
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const SizedBox(height: 100),
                  ),
                  child: const Text('sheet'),
                ),
                Slider(
                  focusNode: sliderFocus,
                  value: 0.5,
                  onChanged: onSlider ?? (_) {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('keys map to playback shortcuts when nothing is in the way',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    await tester.pumpWidget(_app(fired));

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);

    expect(fired, [
      PlaybackShortcut.togglePlay,
      PlaybackShortcut.seekForward,
      PlaybackShortcut.seekBackward,
      PlaybackShortcut.next,
      PlaybackShortcut.toggleShuffle,
    ]);
  });

  testWidgets('typing in a text field never triggers shortcuts',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    await tester.pumpWidget(_app(fired));
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();

    for (final key in [
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyN,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    ]) {
      await tester.sendKeyEvent(key);
    }

    expect(fired, isEmpty);
  });

  testWidgets('shortcuts are silent while a dialog is open, back afterwards',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    await tester.pumpWidget(_app(fired));
    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(fired, isEmpty);

    await tester.tap(find.text('close'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    expect(fired, [PlaybackShortcut.next]);
  });

  testWidgets('shortcuts are silent while a bottom sheet is open',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    await tester.pumpWidget(_app(fired));
    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);

    expect(fired, isEmpty);
  });

  testWidgets('held keys repeat seeking only; modifier combos are ignored',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    await tester.pumpWidget(_app(fired));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    expect(fired, [
      PlaybackShortcut.next,
      PlaybackShortcut.seekForward,
      PlaybackShortcut.seekForward,
    ]);

    fired.clear();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(fired, isEmpty);
  });

  testWidgets('a shortcut key does not also activate the focused button',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    var pressed = 0;
    await tester.pumpWidget(_app(fired, onButton: () => pressed++));

    // Put keyboard focus on the button, as Tab navigation would.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<TextButton>(),
        isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(fired, [
      PlaybackShortcut.togglePlay,
      PlaybackShortcut.seekForward,
      PlaybackShortcut.togglePlay,
    ]);
    expect(pressed, 0, reason: 'Space must only toggle playback');
  });

  testWidgets('a focused slider keeps the arrow keys for itself',
      (tester) async {
    final fired = <PlaybackShortcut>[];
    final sliderFocus = FocusNode();
    addTearDown(sliderFocus.dispose);
    final moved = <double>[];
    await tester.pumpWidget(
        _app(fired, sliderFocus: sliderFocus, onSlider: moved.add));
    sliderFocus.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    expect(moved, isNotEmpty);
    expect(fired, isEmpty);
  });
}
