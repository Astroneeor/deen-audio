import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// One small settings file in the app-support directory.
///
/// Writes are serialized and coalesced: while a write is in flight, newer
/// values simply replace the pending one, so a burst of changes (dragging a
/// slider) can neither interleave on disk nor finish out of order. Each write
/// goes to a temp file that is then renamed over the real one, so a crash
/// mid-write never leaves a truncated settings file behind.
class SettingsFile {
  final String name;

  String? _pending;
  Future<void>? _writer;

  SettingsFile(this.name);

  /// The file's content, or null if it does not exist or cannot be read.
  Future<String?> read() async {
    try {
      final file = await _resolve();
      return file.existsSync() ? file.readAsStringSync() : null;
    } catch (_) {
      return null;
    }
  }

  /// Persists [content]. Completes once it — or a newer value written in the
  /// meantime — is on disk. Never throws: settings persistence is best-effort.
  Future<void> write(String content) {
    _pending = content;
    return _writer ??= _drain();
  }

  Future<void> _drain() async {
    try {
      while (_pending != null) {
        final content = _pending!;
        _pending = null;
        try {
          final file = await _resolve();
          final tmp = File('${file.path}.tmp');
          await tmp.writeAsString(content, flush: true);
          await tmp.rename(file.path);
        } catch (_) {
          // Disk full / read-only profile: keep running with in-memory state.
        }
      }
    } finally {
      _writer = null;
    }
  }

  Future<File> _resolve() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, name));
  }
}
