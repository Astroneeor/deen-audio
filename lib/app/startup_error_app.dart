import 'package:flutter/material.dart';

import '../core/database/connection/native_connection.dart';
import '../core/theme/app_colors.dart';

/// Shown instead of the app when the database cannot be opened at startup:
/// the error and where the database file lives. Nothing else is started.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error, this.databasePath});

  final Object error;

  /// Full path of the database file, when it could be worked out.
  final String? databasePath;

  @override
  Widget build(BuildContext context) {
    final where = databasePath ??
        '$databaseFileName in the app-support folder for Deen Audio';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deen Audio',
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Deen Audio couldn't start",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Its database could not be opened.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    '$error',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    'The database is $where. Check that this folder exists '
                    'and is writable, and that the disk is not full, then '
                    'restart the app.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
