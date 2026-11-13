import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/models/track.dart';
import 'library_repository.dart';

/// Scans a directory tree for audio files and persists them via [LibraryRepository].
///
/// Infers [TrackType] from the top-level sub-folder name:
///   Quran/     → TrackType.quran
///   Adhkar/    → TrackType.adhkar
///   WhiteNoise/ (or Ambient/) → TrackType.whiteNoise
///   Everything else           → TrackType.nasheed
///
/// Artist is the immediate parent folder of the audio file,
/// unless that folder IS the type folder (e.g. Nasheeds/track.mp3 → no artist).
class LibraryScanner {
  final LibraryRepository _repo;

  static const _supportedExtensions = {
    '.mp3', '.m4a', '.flac', '.ogg', '.aac', '.wav', '.opus',
  };
  static const _settingsFileName = 'last_library_folder.txt';

  LibraryScanner(this._repo);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Opens a native directory picker, scans the chosen folder, saves to DB.
  /// Returns the selected path, or null if the user cancelled.
  Future<String?> pickAndScan() async {
    final picked = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select your HalalAudio folder',
    );
    if (picked == null) return null;
    await scanPath(picked);
    return picked;
  }

  /// Scans a specific directory path and saves to DB.
  ///
  /// Throws [LibraryScanException] — leaving the library untouched — when
  /// [dirPath] itself is missing or unreadable (e.g. an unplugged drive).
  Future<void> scanPath(String dirPath) async {
    final found = await _findTracks(dirPath);
    await _repo.replaceAllTracks(found.tracks, keepUnder: found.unreadable);
    await _persistFolder(dirPath);
  }

  /// Returns the last successfully scanned folder path (persisted across restarts).
  Future<String?> getLastFolder() async {
    try {
      final file = await _settingsFile();
      if (!file.existsSync()) return null;
      final content = file.readAsStringSync().trim();
      return content.isEmpty ? null : content;
    } catch (_) {
      return null;
    }
  }

  // ── Scanning ──────────────────────────────────────────────────────────────

  /// Walks the tree under [rootPath] with async I/O (never blocks the UI
  /// isolate). Symlinked folders and files are followed; every real
  /// directory is visited once, so link loops terminate. Sub-folders that
  /// cannot be read are skipped and reported in the result.
  Future<({List<Track> tracks, List<String> unreadable})> _findTracks(
    String rootPath,
  ) async {
    final tracks = <Track>[];
    final unreadable = <String>[];
    final visited = <String>{};
    final pending = <Directory>[Directory(rootPath)];

    while (pending.isNotEmpty) {
      final dir = pending.removeLast();
      try {
        if (!visited.add(await dir.resolveSymbolicLinks())) continue;
        await for (final entity in dir.list(followLinks: true)) {
          if (entity is Directory) {
            pending.add(entity);
          } else if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (_supportedExtensions.contains(ext)) {
              tracks.add(_buildTrack(entity.path, rootPath));
            }
          }
          // Remaining case: a dangling link — nothing to import.
        }
      } on FileSystemException catch (e) {
        if (dir.path == rootPath) {
          throw LibraryScanException(
            'Cannot read folder "$rootPath"'
            '${e.osError == null ? '' : ' (${e.osError!.message})'}',
          );
        }
        unreadable.add(dir.path);
      }
    }
    return (tracks: tracks, unreadable: unreadable);
  }

  Track _buildTrack(String filePath, String rootPath) {
    // Make the path relative to root so we can inspect folder segments.
    final relative = p.relative(filePath, from: rootPath);
    final parts = p.split(relative); // e.g. ['Quran', 'Alafasy', '001.mp3']

    final topFolder = parts.isNotEmpty ? parts[0] : '';
    // Artist = the folder directly containing the file, unless it's the type folder.
    final parentFolder = parts.length >= 2 ? parts[parts.length - 2] : '';
    final artist =
        (parentFolder.isNotEmpty && parentFolder != topFolder) ? parentFolder : null;

    return Track()
      ..title = p.basenameWithoutExtension(filePath)
      ..artist = artist
      ..type = _inferType(topFolder)
      ..filePath = filePath
      ..duration = 0; // updated when track first plays
  }

  TrackType _inferType(String folderName) {
    final l = folderName.toLowerCase();
    if (l.contains('quran')) return TrackType.quran;
    if (l.contains('adhkar') || l.contains('dhikr') || l.contains('azkar')) {
      return TrackType.adhkar;
    }
    if (l.contains('noise') || l.contains('ambient') || l.contains('white')) {
      return TrackType.whiteNoise;
    }
    return TrackType.nasheed;
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persistFolder(String path) async {
    try {
      final file = await _settingsFile();
      await file.writeAsString(path);
    } catch (_) {}
  }

  Future<File> _settingsFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _settingsFileName));
  }
}

/// Thrown when the library root folder cannot be scanned at all.
class LibraryScanException implements Exception {
  final String message;

  const LibraryScanException(this.message);

  @override
  String toString() => message;
}
