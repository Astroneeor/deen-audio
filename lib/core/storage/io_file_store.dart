import 'dart:io';

import 'package:path/path.dart' as p;

import 'file_store.dart';

/// [FileStore] on the real file system, rooted at [base] (in the app the
/// app-support directory).
class IoFileStore implements FileStore {
  IoFileStore(this.base);

  final Directory base;

  String _abs(String rel) {
    final parts = normaliseStorePath(rel).split('/').where((s) => s.isNotEmpty);
    return p.joinAll([base.path, ...parts]);
  }

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
  Future<IOSinkLike> openAppend(String rel) async {
    final file = File(_abs(rel));
    await file.parent.create(recursive: true);
    return _IoSink(file.openWrite(mode: FileMode.append));
  }

  @override
  Future<void> rename(String from, String to) async {
    final target = File(_abs(to));
    await target.parent.create(recursive: true);
    await File(_abs(from)).rename(target.path);
  }

  @override
  Future<void> delete(String rel) async {
    final file = File(_abs(rel));
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> deleteDir(String rel) async {
    final dir = Directory(_abs(rel));
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
