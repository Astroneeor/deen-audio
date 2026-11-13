import 'dart:io';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/database/device_settings_repository.dart';
import 'package:deen_audio/core/models/track.dart';
import 'package:deen_audio/features/library/data/library_repository.dart';
import 'package:deen_audio/features/library/data/library_scanner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/test_database.dart';

/// Records what the scanner hands to the repository.
class _RecordingRepo implements LibraryRepository {
  List<Track>? replaced;
  List<String> keptUnder = const [];

  @override
  Future<void> replaceAllTracks(
    List<Track> tracks, {
    required String libraryRoot,
    Iterable<String> keepUnder = const [],
  }) async {
    replaced = tracks;
    keptUnder = keepUnder.toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory root;
  late _RecordingRepo repo;
  late LibraryScanner scanner;
  late AppDatabase db;
  late DeviceSettingsRepository settings;

  File touch(String relative) =>
      File(p.join(root.path, relative))..createSync(recursive: true);

  Set<String> scannedRelative() => {
        for (final t in repo.replaced!) p.relative(t.filePath, from: root.path),
      };

  setUp(() {
    root = Directory.systemTemp.createTempSync('deen_audio_scan_test');
    repo = _RecordingRepo();
    db = testDatabase();
    settings = DeviceSettingsRepository(db);
    scanner = LibraryScanner(repo, settings);
  });

  tearDown(() async {
    await db.close();
    Process.runSync('chmod', ['-R', 'u+rwx', root.path]);
    root.deleteSync(recursive: true);
  });

  test('remembers the last scanned folder in device settings', () async {
    expect(await scanner.getLastFolder(), isNull);
    touch('Nasheeds/a.mp3');
    await scanner.scanPath(root.path);
    expect(await scanner.getLastFolder(), root.path);
    expect(await settings.read('library.folder'), root.path);
  });

  test('finds audio recursively and infers type and artist from folders',
      () async {
    touch('Quran/Alafasy/001.mp3');
    touch('Nasheeds/track.FLAC');
    touch('WhiteNoise/rain.ogg');
    touch('Quran/Alafasy/cover.jpg');

    await scanner.scanPath(root.path);

    expect(scannedRelative(),
        {'Quran/Alafasy/001.mp3', 'Nasheeds/track.FLAC', 'WhiteNoise/rain.ogg'});
    final quran = repo.replaced!.firstWhere((t) => t.title == '001');
    expect(quran.type, TrackType.quran);
    expect(quran.artist, 'Alafasy');
    final nasheed = repo.replaced!.firstWhere((t) => t.title == 'track');
    expect(nasheed.type, TrackType.nasheed);
    expect(nasheed.artist, isNull);
    expect(repo.replaced!.firstWhere((t) => t.title == 'rain').type,
        TrackType.whiteNoise);
  });

  test('an unreadable sub-folder does not abort the scan', () async {
    touch('Nasheeds/a.mp3');
    touch('Locked/b.mp3');
    final locked = Directory(p.join(root.path, 'Locked'));
    Process.runSync('chmod', ['000', locked.path]);

    await scanner.scanPath(root.path);

    expect(scannedRelative(), {'Nasheeds/a.mp3'});
    expect(repo.keptUnder, [locked.path],
        reason: 'tracks already known under Locked/ must not be dropped');
  }, skip: Platform.isWindows ? 'needs POSIX permissions' : false);

  test('follows symlinked folders and files', () async {
    final external = Directory.systemTemp.createTempSync('deen_audio_ext');
    addTearDown(() => external.deleteSync(recursive: true));
    File(p.join(external.path, 'Alafasy', '002.mp3'))
        .createSync(recursive: true);
    File(p.join(external.path, 'single.mp3')).createSync();
    Link(p.join(root.path, 'Quran')).createSync(external.path);
    Directory(p.join(root.path, 'Nasheeds')).createSync();
    Link(p.join(root.path, 'Nasheeds', 'linked.mp3'))
        .createSync(p.join(external.path, 'single.mp3'));

    await scanner.scanPath(root.path);

    expect(scannedRelative(), containsAll(
        ['Quran/Alafasy/002.mp3', 'Quran/single.mp3', 'Nasheeds/linked.mp3']));
    final t = repo.replaced!.firstWhere((t) => t.title == '002');
    expect(t.type, TrackType.quran);
    expect(t.artist, 'Alafasy');
  }, skip: Platform.isWindows ? 'symlinks need privileges' : false);

  test('a symlink loop terminates and lists each file once', () async {
    touch('Nasheeds/a.mp3');
    Link(p.join(root.path, 'Nasheeds', 'loop')).createSync(root.path);
    Link(p.join(root.path, 'dangling')).createSync('/nonexistent/target');

    await scanner.scanPath(root.path).timeout(const Duration(seconds: 20));

    expect(repo.replaced!.where((t) => t.title == 'a'), hasLength(1));
  }, skip: Platform.isWindows ? 'symlinks need privileges' : false);

  test('a missing root folder throws and leaves the library untouched',
      () async {
    final missing = p.join(root.path, 'unplugged-drive');

    await expectLater(scanner.scanPath(missing),
        throwsA(isA<LibraryScanException>()));
    expect(repo.replaced, isNull,
        reason: 'an unplugged drive must not wipe the library');
  });
}
