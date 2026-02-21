import 'package:go_router/go_router.dart';

import '../features/adhkar/ui/adhkar_screen.dart';
import '../features/library/ui/library_screen.dart';
import '../features/quran/ui/quran_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../shared/widgets/app_scaffold.dart';

/// Route path constants
class AppRoutes {
  AppRoutes._();

  static const String quran = '/quran';
  static const String library = '/library';
  static const String adhkar = '/adhkar';
  static const String settings = '/settings';
}

final router = GoRouter(
  initialLocation: AppRoutes.library,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.quran,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: QuranScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.library,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.adhkar,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdhkarScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
