# Data foundation and download manager — design

Date: 2026-11-13. Status: awaiting owner approval.

## Intent

Deen Audio is heading towards "Quran.com plus an athan app, on desktop first, then
website and phone, with reading tracked across all of them". Accounts and sync will
run on Supabase (Postgres), self-hosted through Coolify. Today everything stays on
the computer.

This design covers the first build step and the groundwork for the last one:

1. Replace the local database (Isar) with SQLite, so the same data layer can run
   on desktop, phone and in a browser, and maps cleanly onto Supabase's Postgres.
2. Shape user data so that turning on accounts later is an upload, not a rewrite.
3. A download manager: the user picks a reciter (or an adhkar audio set), the
   files arrive, and from then on they work offline.

The agreed order after this step: recitation in the reader with follow-along
highlighting → reading tracking → athan notifications → accounts/website/phone.
A UI overhaul is being designed separately.

## Goals

- All existing features keep working on SQLite: library, Quran reader, bookmarks,
  last-read position, adhkar, prayer settings, font size.
- Every piece of user data is sync-ready (see "Sync-ready records").
- A Downloads screen where a user can browse a catalog, download a whole reciter
  or single surahs, pause, resume, cancel, delete, and see disk space used.
- Downloaded surah audio shows up in the Library as Quran tracks and plays through
  the existing audio engine.
- Nothing in screens or providers touches the database engine, the file system or
  the network directly; they go through repositories and three small interfaces
  (below), so the web/phone builds and the sync server are additions.

## Non-goals (this step)

- No server, no sign-in screen, no Supabase project, no actual syncing.
- No web or phone build. The code must not make them harder; it need not run there.
- No follow-along highlighting, no reading statistics UI, no athan (later steps).
  Their tables may be created now where noted, but no UI.
- No search UI. (SQLite full-text search becomes available; using it is a later step.)
- No visual redesign beyond giving the Downloads screen a place in the sidebar.

## Anti-goals

- Altering Quran text or translation in any way. The seed stays byte-identical to
  the bundled Tanzil-derived JSON; `test/quran_assets_test.dart` keeps passing.
- Bundling recitation audio in the installer, or downloading anything the user
  did not ask for.
- Losing user data silently. (There are no real users yet, so a one-time reset on
  first launch of the SQLite build is acceptable — but it must be this once only.)
- A second place where `just_audio` is imported, files over 250 lines, business
  logic in widgets (CLAUDE.md standards still apply).

## Constraints

- Flutter desktop, Riverpod, go_router, just_audio + media_kit backend: unchanged.
- CLAUDE.md currently mandates Isar and an exact dependency list. The owner has
  approved replacing Isar with SQLite and adding an HTTP package. CLAUDE.md and the
  README must be updated as part of this work to say so.
- The Linux native toolchain is not installed on the dev machine yet, so the
  builder can verify with `flutter analyze` and `flutter test` (SQLite in-memory
  databases make repositories unit-testable) but must not claim runtime behaviour.
- Recitation audio licensing is unclear for most public sources. Audio is only
  ever a user-initiated download from the source's own host, with attribution
  shown in the catalog.

## Approaches considered

**Database**

| Option | Trade-off | Verdict |
|---|---|---|
| Keep Isar behind repository interfaces | Least work now; Isar 3 does not run in a browser and is unmaintained, so the website forces a migration of real user data later | Rejected |
| SQLite via the Drift package | Runs on desktop, phone and web; typed queries; full-text search; schema maps directly to Postgres. Costs rewriting five small models and their repositories now, while there is no user data to migrate | **Chosen by owner** |
| Raw `sqlite3`/`sqflite` with hand-written SQL | Fewer dependencies, but no type safety, no web story without extra work | Rejected |

**Getting ready for sync**

| Option | Trade-off | Verdict |
|---|---|---|
| Add sync fields later, when accounts arrive | Nothing to do now; later every table and every row needs migrating and IDs change | Rejected |
| Sync-ready rows now + a no-op sync interface | Small cost per table now; leaves open whether sync is hand-rolled or done with a sync engine (e.g. PowerSync, which pairs SQLite with Supabase) | **Chosen (builder's recommendation, owner agreed to scaffold)** |
| Integrate Supabase client and a sync engine now | Real work against a server that does not exist yet | Rejected for this step |

**Downloads**

| Option | Trade-off | Verdict |
|---|---|---|
| A downloader plugin (background transfer service) | Built for mobile background transfers; extra native code on desktop | Rejected |
| Own small download service on the `http` package, streaming to `.part` files with HTTP Range resume | A few hundred lines, fully testable with a fake HTTP client, works the same on every desktop OS | **Chosen** |

## Design

### Data layer

One Drift database, opened once at startup and provided through Riverpod (replacing
`isarProvider`). Three kinds of table:

**Bundled content — read-only, re-seedable, never synced**
- `surahs` (number PK, name, englishName, englishNameTranslation, numberOfAyahs,
  revelationType), `ayahs` (surahNumber + ayahNumber PK, arabicText, translation).
- Seeded from the existing JSON assets with the existing parser. Seeding keeps its
  current behaviour: versioned (`dataVersion`), done once, parsed off the UI
  thread, clears and reloads only these two tables.

**User data — sync-ready (see next section)**
- `bookmarks` (surahNumber, ayahNumber).
- `settings` (key, JSON value). Replaces the ad-hoc text files:
  `quran_font_size.txt`, `prayer_location.json`, `last_quran_position.txt`,
  `last_library_folder.txt`, `quran_data_version.txt`. One row per key.
- `playlists` and `playlist_items` (playlist id, position, track reference by
  file path or catalog file id — not by local row id).
- `track_states` (track key, isFavorite, lastPlayed). The track key is the
  catalog file id for downloaded audio, or the path relative to the library
  folder for scanned files. This is what makes favourites survive a rescan and
  mean something on another device.
- `reading_sessions` (startedAt, endedAt, surahNumber, fromAyah, toAyah). Table
  only; written by the reading-tracking step later.

**Device-local — not synced**
- `tracks` (the scanned/downloaded library: title, artist, type, filePath,
  duration, surahNumber, trackKey). Rebuilt by scans and by completed downloads.
- `download_items` (catalog file id, pack id, url, local path, bytes total, bytes
  done, status: queued/running/paused/done/failed, error, checksum).

Repositories keep their current public shape where practical
(`LibraryRepository`, `QuranRepository`, …) so providers and screens change as
little as possible. Each repository is constructed from the database and has
unit tests against an in-memory SQLite database.

Isar, `isar_flutter_libs`, `isar_generator` and all `*.g.dart` Isar files are
removed. On first launch of this build the old Isar files and old settings text
files in the app-support directory are deleted once and nothing is imported
(see decision 7).

### Sync-ready records

Every user-data table carries:

| Column | Meaning |
|---|---|
| `id` | UUID text primary key, generated on the device |
| `updated_at` | UTC timestamp, set on every write |
| `deleted_at` | null, or the time it was deleted (rows are hidden, not removed, so a deletion can travel to other devices) |
| `device_id` | UUID of the installation that last wrote it |
| `user_id` | null while the app runs as the local user; set when an account is attached |

All timestamps are stored in UTC. Writes go through one small helper so no
repository forgets to stamp `updated_at`/`device_id`.

Three interfaces, each with one implementation today:

- `AuthSession` — who is using the app. Today: `LocalAuthSession`, a permanent
  "local user" with a generated device id stored in `settings`.
- `SyncService` — `push()`, `pull()`, `status` stream. Today: `NoopSyncService`.
  Repositories do not call it; a later coordinator will read rows changed since
  the last sync using `updated_at`.
- `FileStore` — the only code allowed to touch `dart:io` for app-owned files
  (downloads, later exports): open-for-append, rename, delete, exists, size,
  free space, base directory. Today: `IoFileStore` under the app-support
  directory (`audio/<packId>/<file>`). The library scanner's own folder walking
  stays as it is for now but must sit behind the scanner class, not in widgets.

A short `docs/sync-readiness.md` records the intended Supabase mapping: one
Postgres table per user-data table with the same columns, row-level security on
`user_id = auth.uid()`, last-write-wins on `updated_at`. This is a note for the
future, not something built now.

### Download manager

**Catalog.** A JSON file bundled at `assets/catalog/catalog.json`:
packs → files. A pack has: id, kind (`quranReciter` | `adhkarAudio`; more kinds
later, e.g. translations), title, subtitle (style/riwayah), source name, source
URL for attribution, licence note, and files. A file has: id, title, url, optional
size, optional checksum, and for Quran audio the surah number. The catalog loader
is an interface so a later version can fetch a newer catalog from the owner's own
server; this step ships the bundled one only.

The builder must populate the catalog only with URLs it has actually fetched
(a HEAD or ranged GET succeeding) from sources that publish full-surah MP3s for
direct download, and must record the source and its stated terms in the pack.
Start with a small number of well-known reciters (three to five). No URL may be
written from memory.

**Service.** `DownloadService` (Riverpod provider):
- Queue with at most two files downloading at once.
- Streams the response into `<file>.part` through `FileStore`; on completion
  verifies size (and checksum when the catalog gives one), then renames.
- Resume: if a `.part` exists, request with `Range: bytes=<size>-`; if the server
  answers 200 instead of 206, restart that file from zero.
- Pause, resume, cancel and delete per file and per pack. State lives in
  `download_items`, so an interrupted download is offered for resume after an
  app restart (it does not auto-start network activity on launch).
- Failures (offline, 404, disk full, checksum mismatch) set `failed` with a
  human-readable reason and never leave a renamed-but-broken file behind.
- On completion the file is registered in `tracks` (type quran/adhkar, artist =
  reciter, surahNumber set) so it appears in the Library and, in the next step,
  is what the reader plays.

**Screen.** A new "Downloads" entry in the sidebar:

```
Downloads                                   1.2 GB used
[ Reciters ]  [ Adhkar audio ]

Mishary Alafasy            Murattal · source name
  ████████░░░░  61 of 114 surahs     [Pause] [⋯]
Abdul Basit                Murattal · source name
  Not downloaded                     [Download all] [Choose surahs]
```

"Choose surahs" opens the list of 114 with per-surah state. `⋯` offers delete
and "open source page". An empty shelf (adhkar audio, until a source is agreed)
shows a plain "Nothing here yet" state rather than being hidden. The screen
follows the existing theme; the separate UI overhaul will restyle it with
everything else.

### Dependencies

Added: `drift`, its SQLite native-library package for Flutter, `drift_dev` (dev),
`http`, `uuid`, `crypto`. Removed: `isar`, `isar_flutter_libs`, `isar_generator`.
The builder resolves current versions and setup steps from each package's
current documentation rather than from memory, and confirms `flutter pub get`
resolves alongside the existing audio packages.

## Decisions that pin the design down

These are the designer's calls (not individually discussed with the owner) unless
marked otherwise.

1. **`Track` stays a plain Dart class** (no database annotations) with the fields
   the audio engine already uses, plus `trackKey` and `source`
   (`scanned` | `downloaded`). Drift rows are mapped to and from it inside
   `LibraryRepository`. The audio engine, queue and player bar keep taking `Track`
   and should need no changes beyond removing Isar types. The same applies to
   `Surah`, `Ayah`, `Bookmark`, `Playlist`: plain classes in `core/models/`.
2. **Scanned and downloaded tracks are separate sets.** A rescan replaces only
   `source = scanned` rows. Downloaded rows are added on completion and removed
   only when the user deletes the download.
3. **Downloaded audio shows in the Library even when no library folder is set.**
   The Library's empty state appears only when there are no tracks of either kind,
   and then offers both "Choose a folder" and "Browse downloads".
4. **Paths.** Downloaded files store a path relative to the `FileStore` base
   directory and are resolved to an absolute path when a `TrackSource` is built;
   scanned files store an absolute path as today. `trackKey` is
   `dl:<catalog file id>` for downloads and `lib:<path relative to the library
   folder>` for scanned files.
5. **Settings are split in two tables.** `settings` is user data (sync-ready):
   Quran font size, translation on/off, last-read position, prayer location and
   calculation method. `device_settings` is device-local and never synced:
   device id, library folder path, Quran data version, the one-time-reset marker.
6. **Keys and soft-delete.** Every user-data table has the UUID `id` as primary
   key. Natural keys are unique alongside it: `settings.key`,
   `bookmarks(surah_number, ayah_number)`, `track_states.track_key`,
   `playlist_items(playlist_id, position)`. Re-adding something that was deleted
   revives the existing row (clears `deleted_at`, stamps `updated_at`) rather than
   inserting a second one.
7. **Old data is discarded** (owner-level fact: there are no users yet). Isar is
   removed completely in this step; nothing is read from the old Isar files. The
   old settings text files are not imported. `device_settings` holds a marker so
   cleanup of old files runs once.
8. **The adhkar shelf holds scans, and is empty for now** (owner: adhkar material
   is usually scanned pages, and there is no source yet). The pack kind is
   `adhkarScans`: a pack of image or PDF files. The shelf, the kind and the
   download path are built and exercised by a test fixture catalog; a viewer for
   the scans is a later step. Wherever this document says "adhkar audio" or
   `adhkarAudio`, read `adhkarScans`. Scan files are not registered in `tracks`.
9. **Catalog acceptance.** Full-surah MP3 sources only (per-ayah sources such as
   EveryAyah are for the later follow-along step, not this one). If fewer than
   three reciters can be verified over the network, or the network is unavailable,
   the builder ships what it verified (possibly none), keeps the fixture catalog
   for tests only, and reports that plainly rather than filling the gap.
10. **Web readiness.** The database is opened through a small connection factory
    with a native implementation only; the factory is the single place a web
    implementation would later be added. No web code is written now.
11. **`dart:io` rule applies to new and touched code.** After this step the only
    `dart:io` users are `IoFileStore`, the native database factory and
    `LibraryScanner`. `QuranRepository` and the settings providers lose their file
    access because their values move into the two settings tables;
    `settings_file.dart` is deleted.
12. **First task: confirm SQLite loads under `flutter test` on the dev machine**
    (the native toolchain is missing; a system `libsqlite3` may be what the tests
    load). If it cannot, stop and report before building on it.

## Left to the builder

- Exact Drift table/DAO layout, file names and how repositories are split to
  stay under 250 lines.
- Checksum algorithm handling (use what the source publishes; size-only otherwise).
- Retry/backoff policy for transient network errors.
- Order of work, provided each stage ends with `flutter analyze` clean and
  `flutter test` passing.

## Testing expectations

- Repository tests against in-memory SQLite for every repository, including the
  sync stamps (a write sets `updated_at`/`device_id`; a delete sets `deleted_at`
  and hides the row).
- Quran seeding test: 114 surahs / 6236 ayahs land in the database and text read
  back equals the asset text for a sample of ayahs including 1:1 and 114:6.
- Download service tests with a fake HTTP client and a fake `FileStore`: happy
  path, resume with 206, server ignoring Range (200), cancel mid-file, checksum
  mismatch, failure leaving no final file, queue limit of two.
- Catalog test: the bundled catalog parses, ids are unique, every Quran pack file
  has a surah number in 1–114.

## Open items for the owner

1. Which reciters go in the first catalog (builder will propose three to five
   whose sources it could verify).
2. A source for adhkar audio the owner is happy with; until then that shelf is empty.
