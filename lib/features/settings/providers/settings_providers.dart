import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ── Quran font size ───────────────────────────────────────────────────────────

/// Persisted Quran body font size.  Default 26.  Range 18–48.
class QuranFontSizeNotifier extends StateNotifier<double> {
  static const _defaultSize = 26.0;
  static const _fileName = 'quran_font_size.txt';

  QuranFontSizeNotifier() : super(_defaultSize) {
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final val = double.tryParse(file.readAsStringSync().trim());
      if (val != null && val >= 18 && val <= 48) {
        state = val;
      }
    } catch (_) {}
  }

  Future<void> set(double size) async {
    state = size.clamp(18, 48).toDouble();
    try {
      final file = await _file();
      await file.writeAsString('${state.toStringAsFixed(1)}');
    } catch (_) {}
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}

/// Quran body font size — persisted across restarts.
final quranFontSizeProvider =
    StateNotifierProvider<QuranFontSizeNotifier, double>(
  (ref) => QuranFontSizeNotifier(),
);
