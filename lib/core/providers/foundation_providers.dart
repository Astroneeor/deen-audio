import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/device_settings_repository.dart';
import '../database/settings_repository.dart';
import '../storage/file_store.dart';
import '../sync/auth_session.dart';
import '../sync/sync_service.dart';
import '../sync/sync_stamper.dart';

/// Provides the open [AppDatabase]; overridden in main.dart (and in tests).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with the opened AppDatabase.',
  );
});

/// Provides the current [AuthSession] (the local user with this device's id);
/// overridden in main.dart once the device id has been read.
final authSessionProvider = Provider<AuthSession>((ref) {
  throw UnimplementedError(
    'authSessionProvider must be overridden with a session holding the '
    'device id.',
  );
});

/// Provides the [SyncStamper] every user-data write takes its stamps from.
final syncStamperProvider = Provider<SyncStamper>(
  (ref) => SyncStamper(session: ref.watch(authSessionProvider)),
);

/// Provides the [SyncService]; a no-op until accounts exist.
final syncServiceProvider = Provider<SyncService>(
  (ref) => const NoopSyncService(),
);

/// Provides the [FileStore] for app-owned files; overridden in main.dart with
/// an IoFileStore rooted at the app-support directory.
final fileStoreProvider = Provider<FileStore>((ref) {
  throw UnimplementedError(
    'fileStoreProvider must be overridden with a FileStore.',
  );
});

/// Provides the [DeviceSettingsRepository] (device-local, never synced).
final deviceSettingsRepositoryProvider = Provider<DeviceSettingsRepository>(
  (ref) => DeviceSettingsRepository(ref.watch(appDatabaseProvider)),
);

/// Provides the [SettingsRepository] (user settings, sync-stamped).
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncStamperProvider),
  ),
);
