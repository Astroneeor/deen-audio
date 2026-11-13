/// The minimal write side of a file opened for appending, so tests can fake
/// writes (and write failures) without touching the disk.
abstract class IOSinkLike {
  void add(List<int> data);
  Future<void> flush();
  Future<void> close();
}

/// App-owned files (downloads, later exports). All paths are relative to
/// [basePath] and use `/` as separator; a path that would leave the base
/// directory throws an [ArgumentError].
abstract class FileStore {
  /// Absolute path of the base directory.
  Future<String> basePath();

  Future<bool> exists(String rel);

  /// Size in bytes, or 0 if the file does not exist.
  Future<int> size(String rel);

  /// Reads the whole of [rel] as a byte stream (used to verify checksums).
  Stream<List<int>> openRead(String rel);

  /// Opens [rel] for appending, creating it and its parent directories.
  Future<IOSinkLike> openAppend(String rel);

  /// Moves [from] to [to], replacing [to] if it exists.
  Future<void> rename(String from, String to);

  /// Deletes a file; no-op if it does not exist.
  Future<void> delete(String rel);

  /// Deletes a directory and everything in it; no-op if it does not exist.
  Future<void> deleteDir(String rel);

  /// Absolute path of [rel].
  Future<String> absolute(String rel);

  /// Total size in bytes of all files under [relDir] (0 if missing).
  Future<int> usedBytes(String relDir);
}

/// Normalises a relative store path to `a/b/c` form, rejecting absolute paths
/// and anything that climbs out of the base directory.
String normaliseStorePath(String rel) {
  final unified = rel.replaceAll('\\', '/');
  if (unified.startsWith('/') || RegExp(r'^[A-Za-z]:').hasMatch(unified)) {
    throw ArgumentError.value(rel, 'rel', 'must be a relative path');
  }
  final parts = <String>[];
  for (final part in unified.split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (parts.isEmpty) {
        throw ArgumentError.value(rel, 'rel', 'escapes the base directory');
      }
      parts.removeLast();
    } else {
      parts.add(part);
    }
  }
  return parts.join('/');
}
