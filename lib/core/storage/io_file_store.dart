import 'dart:io';

import 'package:path/path.dart' as p;

import 'file_store.dart';

/// [FileStore] on the real file system, rooted at [base] (in the app the
/// app-support directory).
class IoFileStore implements FileStore {
  IoFileStore(this.base);

  final Directory base;

  String _abs(String rel) => _join(normaliseStorePath(rel));

  /// For mutating operations: never the base directory itself.
  String _absMut(String rel) => _join(normaliseMutablePath(rel));

  String _join(String normalised) => p.joinAll(
      [base.path, ...normalised.split('/').where((s) => s.isNotEmpty)]);

  @override
  Future<String> basePath() async => base.path;

  @override
  Future<String> absolute(String rel) async => _abs(rel);

  @override
  Future<bool> exists(String rel) => File(_abs(rel)).exists();

  @override
  Future<int> size(String rel) async {
    final file = File(_abs(rel));
    return await file.exists() ? await file.length() : 0;
  }

  @override
  Stream<List<int>> openRead(String rel) => File(_abs(rel)).openRead();

  @override
  Future<IOSinkLike> openAppend(String rel) async {
    final file = File(_absMut(rel));
    await file.parent.create(recursive: true);
    return _IoSink(file.openWrite(mode: FileMode.append));
  }

  @override
  Future<void> rename(String from, String to) async {
    final source = File(_absMut(from));
    final target = File(_absMut(to));
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }

  @override
  Future<void> delete(String rel) async {
    final file = File(_absMut(rel));
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> deleteDir(String rel) async {
    final dir = Directory(_absMut(rel));
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  @override
  Future<int> usedBytes(String relDir) async {
    final dir = Directory(_abs(relDir));
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}

class _IoSink implements IOSinkLike {
  _IoSink(this._sink);

  final IOSink _sink;

  @override
  void add(List<int> data) => _sink.add(data);

  @override
  Future<void> flush() => _sink.flush();

  @override
  Future<void> close() => _sink.close();
}
