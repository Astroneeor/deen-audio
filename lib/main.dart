import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/audio/audio_handler.dart';
import 'core/audio/audio_player_service.dart';
import 'core/database/app_database.dart';
import 'core/database/connection/native_connection.dart';
import 'core/database/database_provider.dart';
import 'core/database/device_settings_repository.dart';
import 'core/database/isar_service.dart';
import 'core/providers/foundation_providers.dart';
import 'core/storage/io_file_store.dart';
import 'core/sync/auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialise Isar before anything touches the DB
  final isar = await IsarService.init();

  // 1b. Open the SQLite database (replacing Isar over the next tasks). It is
  //     required: if it cannot be opened this throws and the app does not
  //     start, rather than running without its data.
  final foundation = await _openFoundation();

  // 2. Register the just_audio backend for Linux/Windows (libmpv). Must
  //    happen before the handler creates its player.
  initAudioBackend();

  // 3. Initialise audio_service — registers OS media controls
  //    (Linux MPRIS via audio_service_mpris, Windows SMTC via
  //    audio_service_win, macOS Now Playing built in). The channel id/name
  //    double as the MPRIS bus-name suffix and player identity.
  final audioHandler = await _initAudioHandler();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        audioHandlerProvider.overrideWithValue(audioHandler),
        appDatabaseProvider.overrideWithValue(foundation.db),
        authSessionProvider.overrideWithValue(foundation.session),
        fileStoreProvider.overrideWithValue(foundation.files),
      ],
      child: const DeenAudioApp(),
    ),
  );
}

/// Opens the database, reads (or creates) this installation's device id and
/// roots the file store in the app-support directory.
Future<({AppDatabase db, LocalAuthSession session, IoFileStore files})>
    _openFoundation() async {
  final db = AppDatabase(openNativeConnection());
  try {
    // The connection is lazy: this first query is what opens the file.
    final deviceId = await DeviceSettingsRepository(db).deviceId();
    final files = IoFileStore(await getApplicationSupportDirectory());
    return (
      db: db,
      session: LocalAuthSession(deviceId: deviceId),
      files: files,
    );
  } catch (e) {
    debugPrint('Could not open the Deen Audio database: $e');
    await db.close().catchError((_) {});
    rethrow;
  }
}

/// OS media controls are optional: if the platform side fails (e.g. no D-Bus
/// session bus on Linux) fall back to a plain handler so the app still starts
/// and in-app playback keeps working.
Future<DeenAudioHandler> _initAudioHandler() async {
  DeenAudioHandler? handler;
  try {
    return await AudioService.init<DeenAudioHandler>(
      builder: () => handler = DeenAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.deenaudio.channel.audio',
        androidNotificationChannelName: 'Deen Audio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (e) {
    debugPrint('OS media controls unavailable: $e');
    return handler ?? DeenAudioHandler();
  }
}
