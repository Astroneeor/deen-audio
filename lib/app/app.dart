import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/downloads/providers/download_providers.dart';
import 'router.dart';

/// Root application widget. Uses [MaterialApp.router] with go_router.
class DeenAudioApp extends ConsumerWidget {
  const DeenAudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bring the download service up at launch: it marks downloads left
    // unfinished by the last session as paused (starting nothing) and keeps
    // the Library in step with finished downloads. Failures are logged.
    startDownloadService(ref);
    return MaterialApp.router(
      title: 'Deen Audio',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
