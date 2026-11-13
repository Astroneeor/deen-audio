import 'package:deen_audio/app/router.dart';
import 'package:deen_audio/core/theme/app_colors.dart';
import 'package:deen_audio/shared/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Same shape as the app router (ShellRoute + sibling pages) with stub pages.
GoRouter _router() => GoRouter(
      initialLocation: AppRoutes.library,
      routes: [
        ShellRoute(
          builder: (_, __, child) => Scaffold(
            body: Row(children: [const Sidebar(), Expanded(child: child)]),
          ),
          routes: [
            for (final path in [
              AppRoutes.library,
              AppRoutes.quran,
              AppRoutes.adhkar,
              AppRoutes.prayer,
              AppRoutes.settings,
            ])
              GoRoute(
                path: path,
                pageBuilder: (_, __) =>
                    NoTransitionPage(child: Text('page $path')),
              ),
          ],
        ),
      ],
    );

Color? _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  testWidgets('highlights the active tab and follows navigation',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _router()));
    await tester.pumpAndSettle();

    expect(_labelColor(tester, 'Library'), AppColors.gold);
    expect(_labelColor(tester, 'Quran'), isNot(AppColors.gold));

    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();
    expect(find.text('page /quran'), findsOneWidget);
    expect(_labelColor(tester, 'Quran'), AppColors.gold);
    expect(_labelColor(tester, 'Library'), isNot(AppColors.gold));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('page /settings'), findsOneWidget);
    expect(_labelColor(tester, 'Settings'), AppColors.gold);
    expect(_labelColor(tester, 'Quran'), isNot(AppColors.gold));
  });

  testWidgets('does not overflow in a short window', (tester) async {
    tester.view.physicalSize = const Size(700, 260);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp.router(routerConfig: _router()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
