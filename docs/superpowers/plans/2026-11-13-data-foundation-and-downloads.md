# Data Foundation and Download Manager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Isar with SQLite (Drift), make user data sync-ready, and add a reciter/adhkar download manager with a Downloads screen.

**Architecture:** One Drift `AppDatabase` provided through Riverpod. Plain Dart models in `core/models/`; repositories map rows to models. User-data tables carry sync columns stamped by one helper. Downloads run through a small `DownloadService` on `package:http`, writing through a `FileStore` interface, driven by a bundled JSON catalog.

**Tech Stack:** Flutter desktop, Riverpod, Drift + its Flutter SQLite library package, `http`, `uuid`, `crypto`; existing just_audio/media_kit audio stack unchanged.

**Spec:** `docs/superpowers/specs/2026-11-13-data-foundation-and-downloads-design.md` — read it first, especially "Decisions that pin the design down".

## Global Constraints

- Quran text and translation are never altered; `test/quran_assets_test.dart` keeps passing.
- No file over 250 lines. No business logic in widgets. `lib/core/audio/audio_handler.dart` and `track_source.dart` remain the only `just_audio` importers.
- After Task 5 the only `dart:io` users are `IoFileStore`, the native DB connection factory and `LibraryScanner`.
- All timestamps stored in UTC.
- Package versions and setup come from each package's current pub.dev documentation, not memory; `flutter pub get` must resolve.
- Every task ends with `flutter analyze` → "No issues found!" and `flutter test` → all passing. `flutter run`/`flutter build` cannot be used on this machine; never claim runtime behaviour.
- Do not commit unless the owner has said to; each task's last step is the analyze + test checkpoint.
- Catalog URLs are only ones actually fetched during the task. None from memory.
- Tests live in `test/`, named `<area>_*_test.dart`; shared fakes in `test/support/`.

## Review Focus

1. App closed mid-download, reopened: item is shown as paused with its bytes kept, and nothing starts downloading by itself. (Task 6)
2. Disk full or permission denied while writing a `.part` file: item becomes `failed` with a readable reason, no final file exists. (Task 6)
3. User deletes a downloaded surah while it is the playing track: the row and file go, the library list updates, no crash in the repository layer. (Task 7)
4. Bookmark removed then added again: one row, `deleted_at` cleared, not a unique-constraint error. (Task 2)
5. Rescan while downloads exist: downloaded tracks and all favourites survive. (Task 3)

---

### Task 1: Database core, sync scaffolding, file store

**Files:**
- Create: `lib/core/database/app_database.dart`, `lib/core/database/tables/content_tables.dart`, `tables/user_tables.dart`, `tables/device_tables.dart`, `lib/core/database/connection/native_connection.dart`, `lib/core/database/sync_columns.dart`
- Create: `lib/core/sync/auth_session.dart`, `lib/core/sync/sync_service.dart`, `lib/core/sync/sync_stamper.dart`, `lib/core/storage/file_store.dart`, `lib/core/storage/io_file_store.dart`
- Create: `lib/core/database/device_settings_repository.dart`, `lib/core/database/settings_repository.dart`, `lib/core/providers/foundation_providers.dart`
- Create: `test/support/test_database.dart`, `test/support/memory_file_store.dart`, `test/core_database_test.dart`, `test/core_settings_repository_test.dart`, `test/core_file_store_test.dart`
- Modify: `pubspec.yaml` (add drift, its Flutter sqlite libs package, drift_dev, http, uuid, crypto), `lib/main.dart` (open the DB and override `appDatabaseProvider`; Isar stays for now)

**Interfaces — Produces:**
- `class AppDatabase extends _$AppDatabase { AppDatabase(QueryExecutor e); }` schemaVersion 1, with every table in the spec's "Data layer" section plus `device_settings(key PK, value)`. User-data tables use the `SyncColumns` mixin: `id` (text PK), `updatedAt`, `deletedAt` (nullable), `deviceId`, `userId` (nullable). Unique natural keys per spec decision 6.
- `QueryExecutor openNativeConnection()` in `native_connection.dart` (file `deen_audio.sqlite` in the app-support directory, opened off the UI thread).
- `AppDatabase testDatabase()` in `test/support/test_database.dart` (in-memory).
- `abstract class AuthSession { String get deviceId; String? get userId; }`, `class LocalAuthSession implements AuthSession` (userId always null).
- `class SyncStamper { SyncStamper({required AuthSession session, DateTime Function()? now, String Function()? newId}); String newId(); DateTime nowUtc(); String get deviceId; String? get userId; }`
- `abstract class SyncService { Future<void> push(); Future<void> pull(); Stream<SyncStatus> get status; }`, `enum SyncStatus { disabled, idle, syncing, error }`, `class NoopSyncService` (status emits `disabled`).
- `abstract class FileStore { Future<String> basePath(); Future<bool> exists(String rel); Future<int> size(String rel); Future<IOSinkLike> openAppend(String rel); Future<void> rename(String from, String to); Future<void> delete(String rel); Future<void> deleteDir(String rel); Future<String> absolute(String rel); Future<int> usedBytes(String relDir); }` where `IOSinkLike` is a minimal `add(List<int>)`/`flush()`/`close()` interface defined in the same file. `IoFileStore(Directory base)`; `MemoryFileStore` for tests with an injectable write failure.
- `class DeviceSettingsRepository { Future<String?> read(String key); Future<void> write(String key, String value); Future<String> deviceId(); }` (`deviceId` generates and stores a UUID on first call).
- `class SettingsRepository { Future<Object?> read(String key); Stream<Object?> watch(String key); Future<void> write(String key, Object? jsonValue); Future<void> remove(String key); }` — JSON-encoded values, sync-stamped, `remove` soft-deletes, `write` after `remove` revives the same row.
- Providers in `foundation_providers.dart`: `appDatabaseProvider` (throws unless overridden), `authSessionProvider`, `syncStamperProvider`, `syncServiceProvider`, `fileStoreProvider`, `deviceSettingsRepositoryProvider`, `settingsRepositoryProvider`.

- [ ] **Step 1: Prove SQLite loads under `flutter test`.** Add the dependencies, write `test/core_database_test.dart::opens in-memory database` (open `testDatabase()`, `SELECT 1`). Run `flutter test test/core_database_test.dart`. If the native library cannot load on this machine, stop and report (spec decision 12).
- [ ] **Step 2: Write failing tests.** `core_database_test.dart`: every table exists; inserting two `bookmarks` with the same surah/ayah violates uniqueness. `core_settings_repository_test.dart`: `write` then `read` round-trips a map; `write` stamps `updatedAt` (UTC) and `deviceId`; `remove` hides the value and sets `deletedAt`; `write` after `remove` leaves exactly one row with `deletedAt` null; `watch` emits on change; `DeviceSettingsRepository.deviceId()` returns the same value twice. `core_file_store_test.dart` (against a temp dir): append to a new file, append again and size grows, rename, delete, `usedBytes`.
- [ ] **Step 3: Run them, expect failures** for missing classes.
- [ ] **Step 4: Implement** the files above; run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] **Step 5: Wire `main.dart`**: open `AppDatabase(openNativeConnection())`, resolve the device id, override `appDatabaseProvider` and `authSessionProvider`. Keep the Isar init untouched.
- [ ] **Step 6: Checkpoint** — `flutter analyze`, `flutter test`.

### Task 2: Quran data on SQLite

**Files:**
- Modify: `lib/core/models/surah.dart`, `ayah.dart`, `bookmark.dart` (plain classes, no Isar; delete their `.g.dart`), `lib/features/quran/data/quran_repository.dart`, `lib/features/quran/data/quran_json_parser.dart` (only if model construction changes), `lib/features/quran/providers/quran_providers.dart`, `lib/core/database/isar_service.dart` (drop the three schemas)
- Test: `test/quran_repository_test.dart`; keep `test/quran_assets_test.dart` and `test/quran_reader_ui_test.dart` passing

**Interfaces:**
- Consumes: `AppDatabase`, `SyncStamper`, `SettingsRepository`, `DeviceSettingsRepository`.
- Produces: `QuranRepository(AppDatabase db, SyncStamper stamper, SettingsRepository settings, DeviceSettingsRepository device)` keeping its existing public methods (`isSeeded`, `seed`, `getAllSurahs`, `getAyahs`, `toggleBookmark`, `watchBookmarks`, `saveLastRead`, `getLastRead`, `dataVersion`). Last-read lives in `settings` under key `quran.lastRead` as `{"surah": int, "ayah": int}`; data version in `device_settings` under `quran.dataVersion`. `getLastRead` returns null for a surah outside 1–114 or an ayah beyond that surah's count.

- [ ] **Step 1: Failing tests** in `quran_repository_test.dart` using `testDatabase()` and the real asset files read from disk: after `seed()` there are 114 surahs and 6236 ayahs and `isSeeded()` is true; `getAyahs(1)[0].arabicText` and `getAyahs(114)[5].arabicText` equal the asset JSON strings exactly; a second `seed()` leaves counts unchanged; `toggleBookmark(2,255)` twice then once more yields one visible bookmark and one row total; `watchBookmarks` excludes soft-deleted rows; `saveLastRead(2,255)` round-trips; a stored `{"surah":999,"ayah":1}` reads back as null.
- [ ] **Step 2: Run, expect failures.**
- [ ] **Step 3: Implement.** Seeding inserts in batches inside one transaction and keeps JSON parsing off the UI thread as today. No `dart:io` left in the repository.
- [ ] **Step 4: Checkpoint** — `flutter analyze`, `flutter test`.

### Task 3: Library on SQLite

**Files:**
- Modify: `lib/core/models/track.dart`, `playlist.dart` (plain; delete `.g.dart`), `lib/features/library/data/library_repository.dart`, `library_scanner.dart` (only its persistence of the last folder → `DeviceSettingsRepository` key `library.folder`), `lib/features/library/providers/library_providers.dart`, `lib/core/database/isar_service.dart`, any audio/UI file that used `Isar`-specific `Track` members (`Id`, `Isar.autoIncrement`)
- Test: rewrite `test/library_repository_test.dart` on `testDatabase()`; keep `library_scanner_test.dart`, `library_scan_notifier_test.dart`, `library_screen_test.dart`, `audio_queue_manager_test.dart` passing; delete `test/support/isar_test_lib.dart` when unused

**Interfaces:**
- Produces: `enum TrackSourceKind { scanned, downloaded }`; `class Track { int id; String title; String? artist; TrackType type; String filePath; int duration; bool isFavorite; DateTime? lastPlayed; String? surahNumber; String trackKey; TrackSourceKind source; }` (`filePath` is always absolute by the time a `Track` leaves the repository).
- `LibraryRepository(AppDatabase db, SyncStamper stamper, FileStore files)`: existing methods keep their names (`getAllTracks`, `watchAllTracks`, `replaceAllTracks`, `toggleFavorite`, `markPlayed`) plus `Future<void> upsertDownloadedTrack({required String catalogFileId, required String title, required String artist, required TrackType type, required String relativePath, String? surahNumber})` and `Future<void> removeDownloadedTrack(String catalogFileId)`.
- `replaceAllTracks(List<Track> scanned, {required String libraryRoot, List<String> keepUnder})` touches only `source = scanned` rows. Favourite/lastPlayed are read from and written to `track_states` by `trackKey` (`lib:<relative path>` / `dl:<catalog file id>`), joined into `Track`.

- [ ] **Step 1: Failing tests**: favourite survives `replaceAllTracks` with the same file; a file missing from the new scan is removed but its `track_states` row is kept; `upsertDownloadedTrack` then `replaceAllTracks([])` leaves the downloaded track present; `removeDownloadedTrack` removes it; `toggleFavorite` twice stamps `updatedAt` each time and leaves one `track_states` row; downloaded track's `filePath` is `FileStore.absolute(relativePath)`; `watchAllTracks` emits after each change.
- [ ] **Step 2: Run, expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Checkpoint.**

### Task 4: Settings on SQLite

**Files:**
- Modify: `lib/features/settings/providers/settings_providers.dart`; Delete: `lib/features/settings/data/settings_file.dart`
- Test: update `test/settings_persistence_test.dart`, `test/settings_screen_test.dart`, `test/prayer_*` tests that used the file fakes; delete `test/support/fake_path_provider.dart` if unused

**Interfaces:**
- Consumes: `SettingsRepository`.
- Produces: same notifier/provider names as today (`quranFontSizeProvider`, `locationSettingsProvider`, translation toggle if persisted) backed by keys `quran.fontSize` (number) and `prayer.location` (the existing `LocationSettings.toJson` map, still validated by `fromJson`).

- [ ] **Step 1: Failing tests** against `testDatabase()`: font size set to 40 is read back by a fresh notifier; a value set before the initial load completes is not overwritten (existing regression); invalid stored location (`latitude: 500`) loads as "not set"; two rapid writes leave the last value.
- [ ] **Step 2: Run, expect failures. Step 3: Implement. Step 4: Checkpoint.**

### Task 5: Remove Isar, one-time cleanup, docs

**Files:**
- Delete: `lib/core/database/isar_service.dart`, old `isarProvider`, all `*.g.dart` produced by Isar
- Modify: `pubspec.yaml` (remove `isar`, `isar_flutter_libs`, `isar_generator`), `lib/main.dart`, `lib/core/database/database_provider.dart`, `CLAUDE.md` (stack, models, standards: SQLite/Drift replaces Isar; `http`, `uuid`, `crypto` added), `README.md`
- Create: `lib/core/database/legacy_cleanup.dart`, `docs/sync-readiness.md`, `test/core_legacy_cleanup_test.dart`

**Interfaces:**
- Produces: `Future<void> runLegacyCleanupOnce({required DeviceSettingsRepository device, required FileStore appSupport})` — deletes `deen_audio.isar`, `deen_audio.isar.lock`, `quran_font_size.txt`, `prayer_location.json`, `last_quran_position.txt`, `last_library_folder.txt`, `quran_data_version.txt` if present, then writes `device_settings['legacy.cleaned'] = '1'`; does nothing when the marker exists.

- [ ] **Step 1: Failing test**: files present → removed and marker set; second run with a recreated file leaves that file alone.
- [ ] **Step 2: Implement, call from `main.dart` after the DB opens (errors swallowed and logged, never block startup).**
- [ ] **Step 3: `grep -rn "isar" lib test pubspec.yaml` returns nothing; `grep -rln "dart:io" lib` lists only `io_file_store.dart`, `native_connection.dart`, `library_scanner.dart` (and `main.dart` only if unavoidable — then say why).**
- [ ] **Step 4: Write `docs/sync-readiness.md`** per the spec; update CLAUDE.md and README.
- [ ] **Step 5: Checkpoint.**

### Task 6: Catalog and download service (can run alongside Tasks 2–4; needs Task 1)

**Files:**
- Create: `lib/features/downloads/data/catalog.dart` (models + parser), `catalog_loader.dart`, `download_repository.dart`, `download_service.dart`, `download_models.dart`, `lib/features/downloads/providers/download_providers.dart`, `assets/catalog/catalog.json`, `test/fixtures/catalog_fixture.json`
- Modify: `pubspec.yaml` (`assets/catalog/`), README (catalog sources and attribution)
- Test: `test/downloads_catalog_test.dart`, `test/downloads_service_test.dart`, `test/downloads_repository_test.dart`

**Interfaces:**
- Produces: `enum PackKind { quranReciter, adhkarScans }`; `class CatalogPack { String id; PackKind kind; String title; String? subtitle; String sourceName; String sourceUrl; String? licenceNote; List<CatalogFile> files; }`; `class CatalogFile { String id; String title; Uri url; int? sizeBytes; String? checksum; String? checksumAlgo; int? surahNumber; String fileName; }`; `class Catalog { List<CatalogPack> packs; static Catalog parse(String json); }` (throws `FormatException` on duplicate ids, a `quranReciter` file without a surah number in 1–114, or a non-http(s) URL).
- `abstract class CatalogLoader { Future<Catalog> load(); }`, `AssetCatalogLoader`.
- `enum DownloadStatus { queued, running, paused, done, failed }`; `class DownloadItem { String fileId; String packId; DownloadStatus status; int bytesDone; int? bytesTotal; String? error; String relativePath; }`
- `DownloadRepository(AppDatabase db)`: `watchAll()`, `watchPack(packId)`, `upsert`, `setStatus`, `setProgress`, `delete(fileId)`, `resetRunningToPaused()`.
- `DownloadService({required http.Client client, required FileStore files, required DownloadRepository repo, required Catalog catalog, int maxConcurrent = 2, void Function(CatalogPack, CatalogFile, String relativePath)? onFileDone, void Function(CatalogFile)? onFileRemoved})` with `enqueueFile(fileId)`, `enqueuePack(packId)`, `pause(fileId)`, `pausePack`, `resume(fileId)`, `resumePack`, `cancel(fileId)`, `deleteFile(fileId)`, `deletePack(packId)`, `Future<void> restore()` (calls `resetRunningToPaused`, starts nothing), `Future<int> usedBytes()`. Files are written to `audio/<packId>/<fileName>.part` then renamed.

- [ ] **Step 1: Failing tests.** Catalog: fixture parses; duplicate file id, surah 115, and `ftp://` URL each throw; the bundled `assets/catalog/catalog.json` parses. Service, using `MockClient`-style fake client and `MemoryFileStore`: happy path ends `done`, final file has the bytes, no `.part`, `onFileDone` called once; existing 4-byte `.part` → request carries `Range: bytes=4-`, 206 body appended; server answers 200 to a Range request → file restarted from zero and correct; `pause` mid-stream keeps `.part` and status `paused`; `cancel` removes `.part` and the row; size mismatch → `failed`, no final file; checksum mismatch → `failed`, no final file; 404 → `failed` with a reason containing "404"; write error from the store → `failed` with a readable reason, no final file; five files enqueued never exceed two simultaneous requests; `restore()` after a simulated crash turns `running` into `paused` and issues no request; `deleteFile` removes file, row, and calls `onFileRemoved`.
- [ ] **Step 2: Run, expect failures. Step 3: Implement.**
- [ ] **Step 4: Build the real catalog.** Find three to five well-known reciters whose sources publish full-surah MP3s at stable direct URLs. For each, fetch surah 1 and surah 114 (HEAD or a ranged GET) and record the result. Write only verified packs to `assets/catalog/catalog.json`, with source name, source page URL and the source's stated terms in `licenceNote` (or "No licence stated by source"). Put the `adhkarScans` kind only in the test fixture. If fewer than three verify, ship what verified and report it.
- [ ] **Step 5: Checkpoint.**

### Task 7: Downloads screen and library integration (needs Tasks 3, 5, 6)

**Files:**
- Create: `lib/features/downloads/ui/downloads_screen.dart`, `pack_card.dart`, `pack_files_sheet.dart`, `downloads_empty_shelf.dart`
- Modify: `lib/features/downloads/providers/download_providers.dart` (wire `onFileDone` → `LibraryRepository.upsertDownloadedTrack` for `quranReciter` files, `onFileRemoved` → `removeDownloadedTrack`; call `restore()` at startup), `lib/app/router.dart` (`/downloads`), `lib/shared/widgets/sidebar.dart` (Downloads entry), `lib/features/library/ui/library_empty_state.dart` ("Browse downloads" action)
- Test: `test/downloads_screen_test.dart`, `test/downloads_library_integration_test.dart`, update `test/shared_sidebar_test.dart`

**Interfaces:**
- Consumes: everything from Task 6; `LibraryRepository` from Task 3.
- Produces: `packProgressProvider(packId)` → `({int done, int total, bool anyRunning, bool anyPaused, bool anyFailed})`; `downloadsUsedBytesProvider`.

- [ ] **Step 1: Failing tests.** Widget: Reciters tab lists catalog packs with source name; a pack with nothing downloaded shows "Download all" and "Choose surahs"; a partly downloaded running pack shows "N of M surahs" and "Pause"; a failed file shows its reason and "Retry"; the Adhkar tab with no packs shows the empty-shelf message; narrow width (700px) has no overflow. Integration (real repositories on `testDatabase()`, fake client): completing a `quranReciter` file makes a `downloaded` Quran track appear in `watchAllTracks` with artist = pack title and the right `surahNumber`; `deletePack` removes those tracks; an `adhkarScans` file completes without adding a track.
- [ ] **Step 2: Run, expect failures. Step 3: Implement** in the current theme (the separate UI overhaul restyles it later). **Step 4: Checkpoint.**

---

## Order

Task 1 → then Task 6 in parallel with the chain Task 2 → Task 3 → Task 4 → Task 5 → then Task 7.
