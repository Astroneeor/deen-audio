import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_player_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/library/ui/player_bar.dart';
import 'sidebar.dart';

/// Shell widget wrapping every screen:
///   Sidebar | main content
///   ──────────────────────
///   Persistent PlayerBar
///
/// Also registers global keyboard shortcuts:
///   Space      → play / pause
///   ← / →      → seek ±10 s
///   N           → next track
///   S           → toggle shuffle
class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    // Only act on key-down events; ignore repeats from held keys for seek.
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    // Don't steal keys while a text field is focused.
    final focus = FocusManager.instance.primaryFocus;
    if (focus?.context?.widget is EditableText) return false;

    final svc = ref.read(audioPlayerServiceProvider);

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        if (event is KeyRepeatEvent) return false;
        final playing =
            ref.read(playbackStateProvider).valueOrNull?.playing ?? false;
        playing ? svc.pause() : svc.resume();
        return true;

      case LogicalKeyboardKey.arrowRight:
        final pos =
            ref.read(positionProvider).valueOrNull ?? Duration.zero;
        svc.seek(pos + const Duration(seconds: 10));
        return true;

      case LogicalKeyboardKey.arrowLeft:
        final pos =
            ref.read(positionProvider).valueOrNull ?? Duration.zero;
        final next = pos - const Duration(seconds: 10);
        svc.seek(next.isNegative ? Duration.zero : next);
        return true;

      case LogicalKeyboardKey.keyN:
        if (event is KeyRepeatEvent) return false;
        svc.skipNext();
        return true;

      case LogicalKeyboardKey.keyS:
        if (event is KeyRepeatEvent) return false;
        final shuffled =
            ref.read(queueStateProvider).valueOrNull?.shuffleEnabled ??
                false;
        svc.setShuffleEnabled(!shuffled);
        return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Sidebar(),
                const VerticalDivider(width: 1, color: AppColors.divider),
                Expanded(child: widget.child),
              ],
            ),
          ),
          const ClipRect(child: PlayerBar()),
        ],
      ),
    );
  }
}
