# CLAUDE.md — Deen Audio Desktop
> Halal Spotify. Offline-first. Native. Premium.

Read this file completely before writing any code. Every architectural decision is intentional.

---

## PROJECT VISION

Build a **native desktop application** that is the spiritual equivalent of Spotify — beautifully designed, fast, offline-capable, and deeply integrated with Islamic content.

**Core principle: Frictionless worship.**

Users should be able to open the app, press play, and enter a state of focus/remembrance within 3 seconds. No popups. No ads. No clutter. No loading spinners.

### What this app provides:
- Quran reading with Arabic text + translations
- Quran recitation audio from multiple reciters
- Morning/evening adhkar playlists
- Halal audio library (nasheeds, white noise, dhikr loops)
- Background playback while doing other work
- Fully offline — no internet required after setup

### What this app is NOT (yet):
- A backend-dependent app
- A mobile app
- A social platform
- A streaming service

---

## FINAL TECH STACK (NON-NEGOTIABLE)

```
Framework:         Flutter Desktop
Language:          Dart
State Management:  Riverpod (flutter_riverpod)
Local Database:    Isar
Audio Engine:      just_audio + audio_service + just_audio_background
File Access:       file_picker + path_provider
Routing:           go_router
UI:                Flutter Material 3 + custom theme
```

### Do NOT use:
- Electron (too heavy, bad audio)
- React / any web framework
- Python GUI (Tkinter, PyQt, Kivy)
- Firebase or any cloud services
- Provider (use Riverpod instead)
- GetX
- sqflite manually (use Isar)

### Why Flutter Desktop specifically:
- Single codebase → Windows + macOS + Linux + (later) mobile
- Native performance — not a web wrapper
- Smooth animations comparable to Spotify
- `just_audio` is production-grade and works on desktop
- Isar gives sub-millisecond local queries
- Future streaming server plugs in without UI rewrite

---

## pubspec.yaml (EXACT DEPENDENCIES)

```yaml
name: deen_audio
description: Halal offline-first desktop audio app
version: 0.1.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.13.0'

dependencies:
  flutter:
    sdk: flutter

  # Audio
  just_audio: ^0.9.36
  audio_service: ^0.18.12
  just_audio_background: ^0.0.1-beta.11

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.1

  # File System
  file_picker: ^6.1.1

  # Routing
  go_router: ^13.0.0

  # Utilities
  flutter_hooks: ^0.20.4
  hooks_riverpod: ^2.4.9
  freezed_annotation: ^2.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.3.9
  freezed: ^2.4.5
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
  assets:
    - assets/quran/
    - assets/adhkar/
    - assets/fonts/
```

---

## PROJECT FOLDER STRUCTURE

```
deen_audio/
├── CLAUDE.md                         ← This file
├── pubspec.yaml
├── README.md
│
├── lib/
│   ├── main.dart                     ← Entry point, ProviderScope + AudioService init
│   │
│   ├── app/
│   │   ├── app.dart                  ← MaterialApp.router with theme
│   │   └── router.dart               ← go_router config, all routes
│   │
│   ├── core/
│   │   ├── audio/
│   │   │   ├── audio_player_service.dart     ← Central audio engine (ONLY place just_audio is used)
│   │   │   ├── queue_manager.dart            ← Queue logic, shuffle, repeat
│   │   │   ├── audio_handler.dart            ← audio_service BaseAudioHandler
│   │   │   └── track_source.dart             ← Abstraction: local | remote
│   │   │
│   │   ├── database/
│   │   │   ├── isar_service.dart             ← Isar init and accessor
│   │   │   └── database_provider.dart        ← Riverpod provider for Isar instance
│   │   │
│   │   ├── models/
│   │   │   ├── track.dart                    ← @Collection Isar model
│   │   │   ├── playlist.dart                 ← @Collection Isar model
│   │   │   └── bookmark.dart                 ← @Collection Isar model
│   │   │
│   │   └── theme/
│   │       ├── app_theme.dart                ← Dark theme, colors, typography
│   │       └── app_colors.dart               ← Color constants
│   │
│   ├── features/
│   │   ├── library/
│   │   │   ├── data/
│   │   │   │   ├── library_repository.dart   ← Reads/writes tracks to Isar
│   │   │   │   └── library_scanner.dart      ← Scans folders, extracts metadata
│   │   │   ├── providers/
│   │   │   │   └── library_providers.dart    ← Riverpod providers
│   │   │   └── ui/
│   │   │       ├── library_screen.dart
│   │   │       ├── track_list_tile.dart
│   │   │       └── player_bar.dart           ← Bottom persistent player
│   │   │
│   │   ├── quran/
│   │   │   ├── data/
│   │   │   │   ├── quran_repository.dart     ← Loads JSON, stores in Isar
│   │   │   │   └── quran_json_parser.dart    ← Parses Tanzil JSON
│   │   │   ├── providers/
│   │   │   │   └── quran_providers.dart
│   │   │   └── ui/
│   │   │       ├── quran_screen.dart
│   │   │       ├── surah_list.dart
│   │   │       └── ayah_reader.dart
│   │   │
│   │   └── adhkar/
│   │       ├── data/
│   │       │   └── adhkar_repository.dart    ← Loads adhkar JSON
│   │       ├── providers/
│   │       │   └── adhkar_providers.dart
│   │       └── ui/
│   │           ├── adhkar_screen.dart
│   │           ├── adhkar_list.dart
│   │           └── tasbih_counter.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── sidebar.dart                  ← Left nav sidebar
│       │   └── app_scaffold.dart             ← Shell with sidebar + content
│       └── utils/
│           └── duration_formatter.dart
│
├── assets/
│   ├── quran/
│   │   └── quran_simple.json                 ← Tanzil JSON (download below)
│   ├── adhkar/
│   │   ├── morning.json
│   │   └── evening.json
│   └── fonts/
│       └── (Amiri or Scheherazade for Arabic)
│
└── data/                                     ← NOT bundled in app, user's media dir
    └── (runtime audio files go here or ~/HalalAudio/)
```

---

## CORE MODELS

### Track (Isar Collection)
```dart
@collection
class Track {
  Id id = Isar.autoIncrement;
  late String title;
  String? artist;           // reciter name for Quran, artist for nasheed
  @enumerated
  late TrackType type;      // quran | adhkar | nasheed | whiteNoise
  late String filePath;     // local path today, URL later
  int duration = 0;         // milliseconds
  bool isFavorite = false;
  DateTime? lastPlayed;
  String? surahNumber;      // only for Quran tracks
}

enum TrackType { quran, adhkar, nasheed, whiteNoise }
```

### Playlist (Isar Collection)
```dart
@collection
class Playlist {
  Id id = Isar.autoIncrement;
  late String name;
  List<int> trackIds = [];
  DateTime createdAt = DateTime.now();
}
```

### Bookmark (Isar Collection)
```dart
@collection
class Bookmark {
  Id id = Isar.autoIncrement;
  late int surahNumber;
  late int ayahNumber;
  DateTime savedAt = DateTime.now();
}
```

---

## AUDIO ARCHITECTURE (CRITICAL — READ CAREFULLY)

The entire audio system goes through `AudioPlayerService`. **Nothing else should import `just_audio` directly.**

### TrackSource Abstraction
```dart
abstract class TrackSource {
  Future<AudioSource> toAudioSource();
}

class LocalTrackSource implements TrackSource {
  final String filePath;
  const LocalTrackSource(this.filePath);
  
  @override
  Future<AudioSource> toAudioSource() async {
    return AudioSource.uri(Uri.file(filePath));
  }
}

// Future addition — zero refactor required:
// class RemoteTrackSource implements TrackSource { ... }
```

### AudioPlayerService responsibilities:
- Owns the `AudioPlayer` instance (singleton)
- Exposes streams: `currentTrackStream`, `playbackStateStream`, `positionStream`
- Provides methods: `play()`, `pause()`, `seek()`, `skipNext()`, `skipPrevious()`
- Manages queue internally via `QueueManager`
- Handles background audio via `audio_service`

### AudioHandler (for background/OS media controls):
```dart
class DeenAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // Integrates with OS media controls on Windows/macOS/Linux
  // Lock screen controls, taskbar media buttons, etc.
}
```

---

## DATA SOURCES — WHERE TO GET CONTENT

### 1. Quran Text (JSON)

**Tanzil (recommended — verified, widely trusted)**
- URL: https://tanzil.net/download/
- Download: `quran-simple.json` or `quran-uthmani.json`
- Format: Array of surahs → array of ayahs with Arabic text
- License: Creative Commons (attribution required)

**Alternative: Quran.com data repo**
- URL: https://github.com/quran/quran.com-data
- Contains: text, translations, word-by-word data
- More complex but more feature-rich

**For translations:**
- https://tanzil.net/trans/ — pick any translation, download JSON
- Recommended: `en.sahih` (Saheeh International)

### 2. Quran Recitation Audio (MP3)

**EveryAyah (best for per-ayah files)**
- URL: https://everyayah.com/data/
- Structure: `/<reciter_folder>/001001.mp3` (surah + ayah)
- Many reciters available: Mishary Alafasy, Abdul Basit, etc.
- Bulk download via `wget` or Python script

**Quranic Audio (best for full surahs)**
- URL: https://quranicaudio.com/
- Better audio quality on some reciters
- Download full surah MP3s

**Suggested folder structure after download:**
```
~/HalalAudio/
  Quran/
    MisharyAlafasy/
      001.mp3  (Al-Fatiha)
      002.mp3  (Al-Baqara)
      ...
    AbdulBasit/
      ...
  Adhkar/
    morning_playlist/
    evening_playlist/
  Nasheeds/
  WhiteNoise/
```

### 3. Adhkar Content (JSON)

**Hisnul Muslim (most trusted source)**
- Search GitHub: https://github.com/search?q=hisnul+muslim+json
- Good repo example: https://github.com/saadq/hisnul-muslim-json
- Contains: morning adhkar, evening adhkar, situational duas

**Minimum JSON structure to implement:**
```json
{
  "morning": [
    {
      "id": 1,
      "title": "Ayat al-Kursi",
      "arabic": "اللَّهُ لَا إِلَهَ إِلَّا هُوَ...",
      "transliteration": "Allahu la ilaha illa huwa...",
      "translation": "Allah - there is no deity except Him...",
      "count": 1,
      "reference": "Al-Baqarah 2:255"
    }
  ],
  "evening": [ ... ]
}
```

### 4. Arabic Font (for Quran display)

**Amiri Quran** (best quality, free)
- URL: https://amirifont.org/
- or: https://fonts.google.com/specimen/Amiri

**Scheherazade New** (alternate)
- URL: https://software.sil.org/scheherazade/

### 5. Nasheeds / White Noise

- Source your own royalty-free audio
- Artists who allow free use: check individual licensing
- White noise: https://freesound.org (filter by CC0 license)
- Store locally — the app just scans the folder

---

## UI DESIGN REQUIREMENTS

### Layout: 3-panel desktop layout

```
┌──────────┬────────────────────────────────────┐
│          │                                    │
│ Sidebar  │         Main Content Area          │
│          │                                    │
│ [Quran]  │    (changes per selected tab)      │
│ [Library]│                                    │
│ [Adhkar] │                                    │
│          │                                    │
│ [Settings│                                    │
├──────────┴────────────────────────────────────┤
│         Persistent Bottom Player Bar          │
│  [◀◀] [▶/‖] [▶▶]  [title]  [🔀] [🔁] [vol] │
└───────────────────────────────────────────────┘
```

### Design principles:
- **Dark mode by default** — deep background `#0A0A0F`, not pure black
- **Accent color**: warm gold `#C9A84C` (evokes Islamic art)
- **Arabic text**: Right-to-left, large font size (24px minimum), Amiri Quran font
- **No ads, no banners, no popups ever**
- **Animations**: subtle fade + slide, 200-300ms, no bouncing
- **Sidebar**: icon + label, 220px wide, collapsible

### Inspiration (study these UIs):
- Spotify — bottom player bar, sidebar nav, content grid
- Pocket Casts — queue management UX
- Apple Books — reading view with good typography

---

## DEVELOPMENT PHASES

### Phase 0 — Project Bootstrap (Session 1)
**Goal:** Flutter app launches on desktop, correct folder structure, deps installed.

Tasks for Claude:
1. Run `flutter create --platforms=windows,macos,linux deen_audio`
2. Set up folder structure exactly as specified above
3. Install all pubspec.yaml dependencies
4. Set up Isar initialization in `main.dart`
5. Set up Riverpod `ProviderScope` in `main.dart`
6. Create `AppTheme` with dark colors
7. Set up `go_router` with placeholder screens for 3 tabs
8. Create `AppScaffold` with sidebar + content area shell

**Deliverable:** App launches. Sidebar shows 3 tabs. Dark theme. No crashes.

---

### Phase 1 — Audio Engine (Sessions 2–3)
**Goal:** Play a local MP3 file with full controls.

Tasks for Claude:
1. Implement `TrackSource` abstraction (`track_source.dart`)
2. Implement `DeenAudioHandler` extending `BaseAudioHandler`
3. Implement `AudioPlayerService` with:
   - `play(TrackSource)`, `pause()`, `resume()`, `stop()`
   - `seek(Duration)`, `skipNext()`, `skipPrevious()`
   - Exposed streams for position, state, current track
4. Implement `QueueManager` (list of tracks, index, shuffle mode)
5. Build `PlayerBar` widget (persistent bottom bar):
   - Play/pause button
   - Previous/next
   - Seek slider
   - Track title + artist
   - Volume slider
   - Shuffle + repeat toggles
6. Wire up `AudioPlayerService` as Riverpod provider
7. Add audio service background init to `main.dart`

**Test:** Put any MP3 in `~/HalalAudio/`, hardcode its path, press play, minimize app, audio continues.

---

### Phase 2 — Local Library (Sessions 3–4)
**Goal:** Scan a folder and browse all audio files.

Tasks for Claude:
1. Implement `LibraryScanner`:
   - Uses `file_picker` to let user select `~/HalalAudio/` folder
   - Recursively scans for `.mp3`, `.m4a`, `.flac`, `.ogg`
   - Extracts filename as title, parent folder as artist
   - Infers `TrackType` from subfolder name (`Quran/`, `Nasheeds/`, etc.)
2. Implement `LibraryRepository` (reads/writes `Track` to Isar)
3. Build `LibraryScreen`:
   - Filter tabs: All | Quran | Adhkar | Nasheeds | White Noise
   - Track list with title, artist, duration, type icon
   - Tap to play immediately
   - Long press → add to playlist, favorite
4. Build playlist creation UI (simple dialog, name + track list)
5. Persist last scanned folder path in shared preferences

**Test:** Point app at `~/HalalAudio/`, all files appear, tap plays correctly.

---

### Phase 3 — Quran Reader (Sessions 4–5)
**Goal:** Read Quran offline with Arabic text and translation.

Tasks for Claude:
1. Place `quran_simple.json` (Tanzil) in `assets/quran/`
2. Place translation JSON in `assets/quran/translation_en.json`
3. Implement `QuranJsonParser` to load and parse both files
4. Implement `QuranRepository`:
   - First launch: parse JSON → insert into Isar
   - Subsequent launches: read from Isar
5. Build `QuranScreen`:
   - Surah list on left (114 surahs with Arabic name + English name)
   - Ayah reader on right
6. Build `AyahReader`:
   - Arabic text (Amiri Quran font, right-to-left, large)
   - Translation below each ayah (toggleable)
   - Tap ayah to bookmark
   - Auto-scroll
   - Last-read position persisted in Isar
7. Implement search (Isar full-text search on translations)
8. Bookmark screen showing all saved ayahs

**Test:** Open Quran tab, select Al-Fatiha, see Arabic + English, bookmark ayah 3, close app, reopen, last position restored.

---

### Phase 4 — Adhkar Module (Session 5–6)
**Goal:** Morning/evening adhkar with tasbih counter.

Tasks for Claude:
1. Place `morning.json` and `evening.json` in `assets/adhkar/`
2. Implement `AdhkarRepository` to load JSON
3. Build `AdhkarScreen` with two tabs: Morning / Evening
4. Build `AdhkarList` — each dhikr card shows:
   - Arabic text
   - Translation
   - Count (e.g., "Say 3 times")
   - Reference
5. Build `TasbihCounter`:
   - Large tap target (full screen)
   - Count display
   - Reset button
   - Haptic feedback on desktop (where supported)
   - Custom target count (default 33, 99, etc.)
6. Optional: Local notification reminders for morning/evening

**Test:** Open Adhkar tab, scroll morning adhkar, tap tasbih counter 33 times, counter resets.

---

### Phase 5 — Polish (Sessions 6–7)
**Goal:** It feels like a premium product, not a dev project.

Tasks for Claude:
1. Smooth page transitions (fade + slide, 250ms)
2. Loading states (shimmer skeletons, not spinners)
3. Empty states (friendly message + illustration when library is empty)
4. Keyboard shortcuts:
   - Space → play/pause
   - ← → → seek 10s
   - N → next track
   - S → toggle shuffle
5. Mini player state when sidebar is collapsed
6. Window size persistence (remember last size/position)
7. Settings screen:
   - Change library folder
   - Default reciter
   - Font size for Quran
   - Theme (dark / darker / sepia)
8. System tray integration (keep running, media controls)

---

## HOW TO USE CLAUDE PRO EFFICIENTLY

Claude Pro has context limits. Use these prompts in order:

### Session 1 Prompt:
```
Read CLAUDE.md fully first.

Task: Phase 0 — Project Bootstrap.

1. Give me the exact terminal commands to create the Flutter project with desktop platforms enabled.
2. Create the complete folder structure from CLAUDE.md.
3. Write pubspec.yaml with all dependencies.
4. Write main.dart with Isar init + Riverpod ProviderScope + audio_service init.
5. Write app.dart and router.dart with placeholder screens for Quran, Library, Adhkar.
6. Write AppTheme and AppColors with the dark color palette.
7. Write AppScaffold with sidebar (3 tabs) + content area.

Output: every file with full content, no placeholders, runnable code.
```

### Session 2 Prompt:
```
Read CLAUDE.md fully first. We completed Phase 0.

Task: Phase 1 — Audio Engine.

Existing structure: [paste your current lib/ tree]

Build:
1. track_source.dart — TrackSource abstraction
2. audio_handler.dart — DeenAudioHandler extends BaseAudioHandler
3. audio_player_service.dart — singleton audio engine with queue
4. queue_manager.dart — queue with shuffle/repeat
5. player_bar.dart — persistent bottom player widget
6. Wire AudioPlayerService as Riverpod provider

Requirements from CLAUDE.md:
- No UI code in services
- TrackSource abstraction (local | remote future)
- Background playback via audio_service
- Streams for position, state, current track

Output: every file complete, no TODO stubs.
```

### Session 3 Prompt:
```
Read CLAUDE.md fully first. Phases 0 and 1 are complete.

Task: Phase 2 — Local Library Scanner.

Build:
1. library_scanner.dart — scans folder, infers track types from subfolder names
2. library_repository.dart — CRUD for Track in Isar
3. library_providers.dart — Riverpod providers
4. library_screen.dart — main library view with filter tabs
5. track_list_tile.dart — single track row widget

Use the Track model exactly as defined in CLAUDE.md.
```

### Continue this pattern for each phase.

### Tips to avoid wasting tokens:
- Always paste CLAUDE.md at the start of a new session
- Paste your current file tree so Claude knows what exists
- Ask for one phase at a time
- If Claude starts hallucinating wrong imports, say "check CLAUDE.md for the correct packages"
- Save outputs immediately — don't rely on conversation history

---

## CODING STANDARDS

```
1. No business logic in UI widgets. UI is dumb — it reads providers and calls methods.

2. Every service is a Riverpod provider. No singletons accessed via static methods.

3. Isar models are in core/models/. Features import models, not the other way around.

4. AudioPlayerService is the ONLY class that imports just_audio.

5. File naming: snake_case for files, PascalCase for classes.

6. No file longer than 250 lines. Split if needed.

7. Use Freezed for complex state objects.

8. Every Riverpod provider has a comment explaining what it provides.

9. Arabic text must always use TextDirection.rtl and the Amiri Quran font.

10. Never hardcode file paths. Always use path_provider for user directories.
```

---

## FUTURE FEATURES (DO NOT IMPLEMENT NOW)

Document these here so Claude doesn't accidentally build them:

- [ ] User accounts and authentication
- [ ] Cloud sync or Supabase backend
- [ ] Home server streaming (Rust/Go API)
- [ ] Mobile version (though Flutter makes this easy later)
- [ ] AI tajweed feedback
- [ ] Social/community playlists
- [ ] Podcast support
- [ ] Smart memorization mode
- [ ] Apple Watch / WearOS support
- [ ] Collaborative playlists

When backend is eventually added:
- Server: Rust (Actix-web) or Go (Fiber)
- Database: PostgreSQL
- Storage: S3-compatible (MinIO for self-hosted)
- Auth: JWT
- Deploy: home server behind Caddy reverse proxy

Zero frontend rewrites required because of TrackSource abstraction.

---

## KNOWN CONSTRAINTS

- **Windows**: audio_service background playback works via Windows media session API
- **macOS**: Requires `com.apple.security.network.client` entitlement if ever going online
- **Linux**: Requires `libappindicator3` for system tray. audio_service uses MPRIS.
- **Large audio files**: Do NOT bundle in app assets. Always reference external path.
- **Arabic font**: Must be loaded via `pubspec.yaml` assets — do not rely on system fonts for Arabic.
- **Isar**: Requires running `build_runner` after changing `@collection` classes.

---

## QUICK REFERENCE: KEY COMMANDS

```bash
# Create project
flutter create --platforms=windows,macos,linux deen_audio

# Install deps
flutter pub get

# Generate Isar + Riverpod code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on Windows
flutter run -d windows

# Run on Linux
flutter run -d linux

# Build Windows release
flutter build windows --release

# Build Linux release
flutter build linux --release
```

---

## SUCCESS CRITERIA FOR MVP

Before calling v1.0 done, verify:

- [ ] App launches in under 2 seconds
- [ ] Playing audio continues when app is minimized
- [ ] OS media controls (taskbar) work
- [ ] Quran loads offline with no internet
- [ ] Arabic text renders correctly (right-to-left, no garbled characters)
- [ ] Bookmarks persist after closing app
- [ ] Library scan finds all audio in ~/HalalAudio/
- [ ] Tap a track in library → it plays
- [ ] Skip next/previous works in queue
- [ ] Adhkar counter increments and resets
- [ ] App looks clean and premium — not like a student project

---

*This is a sadaqah-jariyah project. Build it with the same care you would any serious product.*
