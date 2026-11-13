import 'package:deen_audio/features/library/data/library_scanner.dart';
import 'package:deen_audio/features/library/providers/library_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeScanner implements LibraryScanner {
  String? lastFolder;
  String? pickResult;
  Object? scanError;
  final scanned = <String>[];

  @override
  Future<String?> getLastFolder() async => lastFolder;

  @override
  Future<String?> pickAndScan() async {
    final picked = pickResult;
    if (picked != null) await scanPath(picked);
    return picked;
  }

  @override
  Future<void> scanPath(String dirPath) async {
    if (scanError != null) throw scanError!;
    scanned.add(dirPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeScanner scanner;

  Future<ScanNotifier> restored() async {
    final n = ScanNotifier(scanner);
    await pumpEventQueue();
    return n;
  }

  setUp(() => scanner = _FakeScanner()..lastFolder = '/home/u/HalalAudio');

  test('restores the last folder on startup', () async {
    final n = await restored();
    expect(n.state.valueOrNull, '/home/u/HalalAudio');
  });

  test('cancelling the folder picker keeps the current folder', () async {
    final n = await restored();
    scanner.pickResult = null; // user pressed Cancel

    await n.pickAndScan();

    expect(n.state.isLoading, isFalse);
    expect(n.state.valueOrNull, '/home/u/HalalAudio');
  });

  test('picking a folder switches to it', () async {
    final n = await restored();
    scanner.pickResult = '/mnt/music';

    await n.pickAndScan();

    expect(n.state.valueOrNull, '/mnt/music');
    expect(scanner.scanned, ['/mnt/music']);
  });

  test('rescan re-reads the current folder without asking', () async {
    final n = await restored();

    await n.rescan();

    expect(scanner.scanned, ['/home/u/HalalAudio']);
    expect(n.state.valueOrNull, '/home/u/HalalAudio');
  });

  test('a failed scan reports the error and keeps the folder for a retry',
      () async {
    final n = await restored();
    scanner.scanError = const LibraryScanException('Cannot read folder');

    await n.rescan();

    expect(n.state.hasError, isTrue);
    expect(n.state.error.toString(), 'Cannot read folder');
    expect(n.state.valueOrNull, '/home/u/HalalAudio');

    scanner.scanError = null;
    await n.rescan();
    expect(n.state.hasError, isFalse);
    expect(scanner.scanned, ['/home/u/HalalAudio']);
  });

  test('a slow startup restore does not clobber a folder picked meanwhile',
      () async {
    final n = ScanNotifier(scanner); // restore still pending
    scanner.pickResult = '/mnt/music';
    await n.pickAndScan();
    await pumpEventQueue();
    expect(n.state.valueOrNull, '/mnt/music');
  });
}
