import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_player_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/library/ui/player_bar.dart';
import 'playback_shortcut_scope.dart';
import 'sidebar.dart';

/// Shell widget wrapping every screen:
///   Sidebar | main content
///   ──────────────────────
///   Persistent PlayerBar
///
/// Also wires the global keyboard shortcuts (see [PlaybackShortcutScope] for
/// when they are suppressed):
///   Space      → play / pause
///   ← / →      → seek ±10 s
///   N           → next track
///   S           → toggle shuffle
class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  void _onShortcut(WidgetRef ref, PlaybackShortcut shortcut) {
    final svc = ref.read(audioPlayerServiceProvider);
    final position = ref.read(positionProvider).valueOrNull ?? Duration.zero;

    switch (shortcut) {
      case PlaybackShortcut.togglePlay:
        final playing =
            ref.read(playbackStateProvider).valueOrNull?.playing ?? false;
        playing ? svc.pause() : svc.resume();
      case PlaybackShortcut.seekForward:
        svc.seek(position + const Duration(seconds: 10));
      case PlaybackShortcut.seekBackward:
        final target = position - const Duration(seconds: 10);
        svc.seek(target.isNegative ? Duration.zero : target);
      case PlaybackShortcut.next:
        svc.skipNext();
      case PlaybackShortcut.toggleShuffle:
        final shuffled =
            ref.read(queueStateProvider).valueOrNull?.shuffleEnabled ?? false;
        svc.setShuffleEnabled(!shuffled);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaybackShortcutScope(
      onShortcut: (shortcut) => _onShortcut(ref, shortcut),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Sidebar(),
                  const VerticalDivider(width: 1, color: AppColors.divider),
                  Expanded(child: child),
                ],
              ),
            ),
            const PlayerBar(),
          ],
        ),
      ),
    );
  }
}
