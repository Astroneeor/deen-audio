import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/audio/audio_handler.dart';
import 'core/audio/audio_player_service.dart';
import 'core/database/database_provider.dart';
import 'core/database/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialise Isar before anything touches the DB
  final isar = await IsarService.init();

  // 2. Initialise audio_service — registers OS media controls
  //    (Linux MPRIS, Windows SMTC, macOS Media Center)
  //    Returns our typed handler so we can inject it via Riverpod.
  final audioHandler = await AudioService.init<DeenAudioHandler>(
    builder: () => DeenAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.deenaudio.channel.audio',
      androidNotificationChannelName: 'Deen Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const DeenAudioApp(),
    ),
  );
}
