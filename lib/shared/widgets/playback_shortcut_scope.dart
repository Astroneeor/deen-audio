import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global playback actions reachable from the keyboard.
enum PlaybackShortcut {
  togglePlay, // Space
  seekForward, // →
  seekBackward, // ←
  next, // N
  toggleShuffle, // S
}

/// Listens for the app-wide playback keys around [child] and reports them
/// through [onShortcut].
///
/// A key is left alone (and keeps its normal meaning) when:
/// * it is combined with Ctrl / Alt / Meta;
/// * the user is typing in a text field;
/// * a dialog, bottom sheet or popup menu is open;
/// * a focused control inside [child] consumes it first (e.g. a slider
///   handling the arrow keys).
///
/// Otherwise the key is consumed, so it cannot *also* activate whichever
/// button happens to hold keyboard focus or move focus around. Holding a key
/// repeats seeking only.
class PlaybackShortcutScope extends StatefulWidget {
  final ValueChanged<PlaybackShortcut> onShortcut;
  final Widget child;

  const PlaybackShortcutScope({
    super.key,
    required this.onShortcut,
    required this.child,
  });

  @override
  State<PlaybackShortcutScope> createState() => _PlaybackShortcutScopeState();
}

class _PlaybackShortcutScopeState extends State<PlaybackShortcutScope> {
  static final _keys = <LogicalKeyboardKey, PlaybackShortcut>{
    LogicalKeyboardKey.space: PlaybackShortcut.togglePlay,
    LogicalKeyboardKey.arrowRight: PlaybackShortcut.seekForward,
    LogicalKeyboardKey.arrowLeft: PlaybackShortcut.seekBackward,
    LogicalKeyboardKey.keyN: PlaybackShortcut.next,
    LogicalKeyboardKey.keyS: PlaybackShortcut.toggleShuffle,
  };

  /// Never takes focus itself; it only sees keys bubbling up from [child].
  final _node = FocusNode(
    debugLabel: 'PlaybackShortcutScope',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _node.dispose();
    super.dispose();
  }

  /// Covers the case where keyboard focus is outside [child] (nothing
  /// focused yet, or focus resting on the window's root scope). When focus is
  /// inside [child], [_onFocusKey] handles the event instead, after the
  /// focused control has had its chance.
  bool _onGlobalKey(KeyEvent event) {
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary.ancestors.contains(_node)) return false;
    return _handle(event) == KeyEventResult.handled;
  }

  KeyEventResult _onFocusKey(FocusNode node, KeyEvent event) => _handle(event);

  KeyEventResult _handle(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final shortcut = _keys[event.logicalKey];
    if (shortcut == null) return KeyEventResult.ignored;

    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext != null &&
        focusContext.mounted &&
        (_isTextInput(focusContext) || _isInsidePopup(focusContext))) {
      return KeyEventResult.ignored;
    }

    final seeking = shortcut == PlaybackShortcut.seekForward ||
        shortcut == PlaybackShortcut.seekBackward;
    if (event is KeyDownEvent || seeking) widget.onShortcut(shortcut);
    return KeyEventResult.handled;
  }

  /// A focused text field's focus node is attached to the `Focus` widget
  /// that [EditableText] builds, so the EditableText is an *ancestor* of the
  /// focus context rather than the context's own widget.
  static bool _isTextInput(BuildContext focusContext) =>
      focusContext.widget is EditableText ||
      focusContext.findAncestorWidgetOfExactType<EditableText>() != null;

  /// Opening a dialog / sheet / menu moves keyboard focus into its route, so
  /// the route enclosing the focused widget tells us whether one is open.
  static bool _isInsidePopup(BuildContext focusContext) =>
      ModalRoute.of(focusContext) is PopupRoute;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      onKeyEvent: _onFocusKey,
      child: widget.child,
    );
  }
}
