import 'dart:convert';
import 'dart:io';

import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/data/download_repository.dart';
import 'package:deen_audio/features/downloads/data/download_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_download_server.dart';
import 'memory_file_store.dart';
import 'test_database.dart';

/// Ids and paths from test/fixtures/catalog_fixture.json.
const fatiha = 'test-reciter-001';
const fatihaUrl = '/audio/001.mp3';
const fatihaFinal = 'audio/test-reciter/001.mp3';
const fatihaPart = 'audio/test-reciter/001.mp3.part';
const fatihaBody = [1, 2, 3, 4, 5, 6, 7, 8];
const ikhlaas = 'test-reciter-112';

/// Shared setup for DownloadService tests: in-memory database and file
/// store, the fixture catalog, and a [FakeDownloadServer] serving a body for
/// every fixture file. Wire it with `setUp(h.setUp); tearDown(h.tearDown);`.
class DownloadHarness {
  late AppDatabase db;
  late MemoryFileStore files;
  late DownloadRepository repo;
  late Catalog catalog;
  late FakeDownloadServer server;
  late DownloadService service;
  final done = <(CatalogPack, CatalogFile, String)>[];
  final removed = <CatalogFile>[];

  void setUp() {
    db = testDatabase();
    files = MemoryFileStore(base: '/store');
    repo = DownloadRepository(db);
    catalog = Catalog.parse(
      File('test/fixtures/catalog_fixture.json').readAsStringSync(),
    );
    server = FakeDownloadServer({
      fatihaUrl: fatihaBody,
      '/audio/112.mp3': utf8.encode('ikhlaas!'),
      '/audio/113.mp3': [13, 13, 13],
      '/audio/114.mp3': [14, 14, 14, 14],
      '/audio/002.mp3': [2, 2],
      '/scans/morning-1.jpg': [0xff, 0xd8, 0xff],
      '/scans/evening.pdf': utf8.encode('%PDF-1.4'),
    });
    done.clear();
    removed.clear();
    service = newService();
  }

  DownloadService newService({
    int maxConcurrent = 2,
    Duration stallTimeout = const Duration(seconds: 30),
    Duration progressInterval = const Duration(milliseconds: 500),
    DownloadRepository? repository,
  }) => DownloadService(
    client: server.client,
    files: files,
    repo: repository ?? repo,
    catalog: catalog,
    maxConcurrent: maxConcurrent,
    stallTimeout: stallTimeout,
    progressInterval: progressInterval,
    onFileDone: (pack, file, rel) => done.add((pack, file, rel)),
    onFileRemoved: removed.add,
  );

  /// Replaces [service] (disposing the old one) with one built by [make].
  Future<void> replaceService(DownloadService Function() make) async {
    await service.dispose();
    service = make();
  }

  Future<DownloadItem> row(String id) async => (await repo.get(id))!;

  /// Starts [fatiha] with held bodies and delivers its first 3 bytes.
  Future<void> startHeld() async {
    server.hold = true;
    await service.enqueueFile(fatiha);
    await pumpEventQueue();
    server.held[fatihaUrl]!.add([1, 2, 3]);
    await pumpEventQueue();
  }

  Future<void> tearDown() async {
    await service.dispose();
    await db.close();
  }
}
