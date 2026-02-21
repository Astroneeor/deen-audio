import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'isar_service.dart';

/// Provides the initialized Isar instance throughout the app.
/// Must be overridden at startup with the initialized instance via ProviderScope overrides.
final isarProvider = Provider<Isar>((ref) {
  return IsarService.instance;
});
