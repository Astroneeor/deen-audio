import 'package:deen_audio/core/storage/file_store.dart';
import 'package:path/path.dart' as p;

/// In-memory [FileStore] for tests. Set [writeError] to make every subsequent
/// `add` on an open sink throw it (e.g. a disk-full `FileSystemException`).
class MemoryFileStore implements FileStore {
  MemoryFileStore({this.base = '/memory'});

  final String base;

  /// Normalised relative path → contents.
  final Map<String, List<int>> files = {};

  Object? writeError;

  /// Contents of [rel], or null if it does not exist.
  List<int>? bytesOf(String rel) => files[normaliseStorePath(rel)];

  bool _under(String path, String dir) =>
      dir.isEmpty || path == dir || path.startsWith('$dir/');

  @override
  Future<String> basePath() async => base;

  @override
  Future<String> absolute(String rel) async =>
      p.joinAll([base, ...normaliseStorePath(rel).split('/')]);

  @override
  Future<bool> exists(String rel) async =>
      files.containsKey(normaliseStorePath(rel));

  @override
  Future<int> size(String rel) async => bytesOf(rel)?.length ?? 0;

  @override
  Future<IOSinkLike> openAppend(String rel) async {
    final key = normaliseStorePath(rel);
    files.putIfAbsent(key, () => <int>[]);
    return _MemorySink(this, key);
  }

  @override
  Future<void> rename(String from, String to) async {
    final data = files.remove(normaliseStorePath(from));
    if (data == null) throw StateError('No such file: $from');
    files[normaliseStorePath(to)] = data;
  }

  @override
  Future<void> delete(String rel) async =>
      files.remove(normaliseStorePath(rel));

  @override
  Future<void> deleteDir(String rel) async {
    final dir = normaliseStorePath(rel);
    files.removeWhere((path, _) => _under(path, dir));
  }

  @override
  Future<int> usedBytes(String relDir) async {
    final dir = normaliseStorePath(relDir);
    return files.entries
        .where((e) => _under(e.key, dir))
        .fold<int>(0, (sum, e) => sum + e.value.length);
  }
}

class _MemorySink implements IOSinkLike {
  _MemorySink(this._store, this._key);

  final MemoryFileStore _store;
  final String _key;

  @override
  void add(List<int> data) {
    final error = _store.writeError;
    if (error != null) throw error;
    _store.files.putIfAbsent(_key, () => <int>[]).addAll(data);
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}
