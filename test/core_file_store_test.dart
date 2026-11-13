import 'dart:io';

import 'package:deen_audio/core/storage/file_store.dart';
import 'package:deen_audio/core/storage/io_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/memory_file_store.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('deen_file_store'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  final stores = <String, FileStore Function()>{
    'IoFileStore': () => IoFileStore(dir),
    'MemoryFileStore': () => MemoryFileStore(),
  };

  stores.forEach((name, make) {
    group(name, () {
      Future<void> append(FileStore s, String rel, List<int> bytes) async {
        final sink = await s.openAppend(rel);
        sink.add(bytes);
        await sink.flush();
        await sink.close();
      }

      test('append to a new file, then again: size grows', () async {
        final s = make();
        expect(await s.exists('audio/pack/a.part'), isFalse);
        await append(s, 'audio/pack/a.part', [1, 2, 3]);
        expect(await s.exists('audio/pack/a.part'), isTrue);
        expect(await s.size('audio/pack/a.part'), 3);
        await append(s, 'audio/pack/a.part', [4, 5]);
        expect(await s.size('audio/pack/a.part'), 5);
      });

      test('rename, delete, usedBytes, deleteDir', () async {
        final s = make();
        await append(s, 'audio/pack/a.part', [1, 2, 3, 4]);
        await append(s, 'audio/pack/b.mp3', [9, 9]);
        await append(s, 'other/c.bin', [7]);

        await s.rename('audio/pack/a.part', 'audio/pack/a.mp3');
        expect(await s.exists('audio/pack/a.part'), isFalse);
        expect(await s.size('audio/pack/a.mp3'), 4);
        expect(await s.usedBytes('audio'), 6);
        expect(await s.usedBytes('missing'), 0);

        await s.delete('audio/pack/b.mp3');
        expect(await s.exists('audio/pack/b.mp3'), isFalse);
        expect(await s.usedBytes('audio'), 4);
        await s.delete('audio/pack/never-existed.mp3');

        await s.deleteDir('audio/pack');
        expect(await s.exists('audio/pack/a.mp3'), isFalse);
        expect(await s.usedBytes('audio'), 0);
        expect(await s.usedBytes('other'), 1);
      });

      test('openRead returns the contents', () async {
        final s = make();
        await append(s, 'audio/pack/r.bin', [1, 2, 3]);
        await append(s, 'audio/pack/r.bin', [4]);
        final read = await s
            .openRead('audio/pack/r.bin')
            .fold<List<int>>([], (all, c) => all..addAll(c));
        expect(read, [1, 2, 3, 4]);
      });

      test('absolute resolves under basePath', () async {
        final s = make();
        final base = await s.basePath();
        expect(
            await s.absolute('audio/x/y.mp3'), p.join(base, 'audio/x/y.mp3'));
      });

      test('paths escaping the base are rejected', () async {
        final s = make();
        expect(() => s.absolute('../outside.txt'), throwsArgumentError);
        expect(() => s.openAppend('/etc/passwd'), throwsArgumentError);
      });
    });
  });

  test('IoFileStore writes real files under the base directory', () async {
    final s = IoFileStore(dir);
    final sink = await s.openAppend('audio/p/f.bin');
    sink.add([1, 2]);
    await sink.close();
    expect(File(p.join(dir.path, 'audio', 'p', 'f.bin')).readAsBytesSync(),
        [1, 2]);
  });

  test('MemoryFileStore write errors surface from flush/close, like IOSink',
      () async {
    final s = MemoryFileStore()
      ..writeError = const FileSystemException('disk full');
    final sink = await s.openAppend('audio/p/f.part');
    sink.add([1]); // does not throw
    await expectLater(sink.flush(), throwsA(isA<FileSystemException>()));
    expect(await s.size('audio/p/f.part'), 0);

    final sink2 = await s.openAppend('audio/p/g.part');
    sink2.add([1]);
    await expectLater(sink2.close(), throwsA(isA<FileSystemException>()));
  });
}
