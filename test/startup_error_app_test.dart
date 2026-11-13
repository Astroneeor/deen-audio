// The screen shown instead of the app when the database cannot be opened.
import 'package:deen_audio/app/startup_error_app.dart';
import 'package:deen_audio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the error and where the database lives', (tester) async {
    await tester.pumpWidget(const StartupErrorApp(
      error: 'SqliteException(14): unable to open database file',
      databasePath: '/home/u/.local/share/deen_audio/deen_audio.sqlite',
    ));

    expect(find.text("Deen Audio couldn't start"), findsOneWidget);
    expect(find.textContaining('unable to open database file'), findsOneWidget);
    expect(
      find.textContaining('/home/u/.local/share/deen_audio/deen_audio.sqlite'),
      findsOneWidget,
    );
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.background);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without a known path it still explains the problem',
      (tester) async {
    await tester.pumpWidget(const StartupErrorApp(error: 'boom'));

    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.textContaining('deen_audio.sqlite'), findsOneWidget);
  });
}
