# Deen Audio

Offline-first Islamic desktop audio player — Spotify for halal content.

## Features

- **Audio library** — scan any local folder; plays MP3, M4A, FLAC, OGG, AAC, WAV, Opus; auto-detects type (Quran / Adhkar / Nasheed / White Noise) from sub-folder name
- **Quran reader** — side-by-side surah list and ayah reader; Arabic text (RTL, Amiri font); English translation toggle; per-ayah bookmarks; last-read position restored on relaunch
- **Adhkar** — morning and evening dhikr cards with Arabic text, transliteration, translation, and repetition count; built-in tasbih counter (33 / 99 / ∞ targets)
- **Persistent player bar** — play/pause, previous/next, seek slider, shuffle, repeat, volume; OS media controls (Linux MPRIS, Windows SMTC, macOS Media Center)
- **Keyboard shortcuts** — `Space` play/pause · `←/→` seek ±10 s · `N` next track · `S` toggle shuffle
- **Settings** — change library folder, adjust Quran font size (persisted), rescan library
- **Dark theme** — deep background with warm gold accent; shimmer loading skeletons; no ads, no internet required

---

## Requirements

- Flutter 3.41 or later (`flutter --version`) — the SQLite package (`sqlite3` 3.x, used through Drift) relies on Dart build hooks
- Dart SDK ≥ 3.11 (bundled with Flutter 3.41)

### Linux

```bash
# Build toolchain
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev lld build-essential

# Audio playback (needed to run the app, not to compile it)
sudo apt install libmpv2
```

- `lld` is required when Flutter is installed via snap. Without it the linker step fails.
- `libmpv2` provides `libmpv.so.2`, which the audio backend (`just_audio_media_kit` / `media_kit`) loads at startup. Without it the app still opens but nothing plays; the console prints `Audio backend unavailable`. On other distros install the package that ships `libmpv.so.2` (often `mpv-libs` or `libmpv`).
- `build-essential` (`make` + a C compiler) is used by `media_kit_libs_linux`, which downloads and compiles mimalloc during the first build, so that build needs internet access.
- SQLite needs no system package: `package:sqlite3`'s build hook downloads a prebuilt SQLite library for the target platform during the first `flutter run`/`build`/`test` (internet needed once; it is cached afterwards) and bundles it with the app. The same applies on macOS and Windows.
- Media keys and the desktop media widget use MPRIS over the D-Bus session bus (`audio_service_mpris`); no extra package is needed on a standard desktop session.

### macOS

Xcode command-line tools:

```bash
xcode-select --install
```

### Windows

Visual Studio 2022 with the **Desktop development with C++** workload (installer → Individual components → MSVC + Windows SDK).

---

## Build & run

```bash
# 1. Clone
git clone <repo-url>
cd deen-audio

# 2. Dependencies
flutter pub get

# 3. Generate the Drift database code (required after any table change in
#    lib/core/database/tables/)
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run -d linux      # Linux
flutter run -d macos      # macOS
flutter run -d windows    # Windows

# Release builds
flutter build linux   --release
flutter build macos   --release
flutter build windows --release
```

---

## Content setup

The complete Quran text, an English translation and the Quran font ship with the app — the reader works fully offline with no setup. Only recitation audio has to be added by you.

### 1. Quran text and translation (bundled)

| File | Content | Source |
|------|---------|--------|
| `assets/quran/quran_simple.json` | All 114 surahs / 6236 ayahs, Uthmani text | [Tanzil](https://tanzil.net) Quran Text, Uthmani, version 1.1 |
| `assets/quran/translation_en.json` | Saheeh International (English) | [tanzil.net/trans](https://tanzil.net/trans/) — `en.sahih` |

**Attribution.** The Quran text is © 2007–2026 [Tanzil Project](https://tanzil.net), licensed under Creative Commons Attribution 3.0. It is included verbatim: Tanzil's terms forbid changing the text and require that the source be indicated with a link to [tanzil.net](https://tanzil.net) so users can keep track of updates. The full notices are in `assets/quran/TANZIL_LICENSE.txt`. Never edit the JSON files by hand.

The ayah text is byte-for-byte what Tanzil publishes. In particular, Tanzil prefixes the basmala to ayah 1 of every surah except Al-Fatiha (where it is ayah 1) and At-Tawba (which has none); the app leaves it there.

To regenerate the files (for example after a Tanzil update), download the sources into an empty directory and run the converter:

```bash
mkdir /tmp/quran-dl && cd /tmp/quran-dl
curl -L -o tanzil-uthmani-default.txt \
  "https://tanzil.net/pub/download/index.php?marks=true&sajdah=true&tatweel=true&quranType=uthmani&outType=txt-2&agree=true"
curl -L -o tanzil-en-sahih.txt https://tanzil.net/trans/en.sahih
curl -L -o tanzil-quran-data.xml https://tanzil.net/res/text/metadata/quran-data.xml

cd <repo root>
python3 -I tools/build_quran_assets.py /tmp/quran-dl assets/quran
flutter test test/quran_assets_test.dart
```

The converter pins the SHA-256 of the source files and refuses changed ones unless `--allow-new-version` is passed. After changing the data, bump `QuranRepository.dataVersion` in `lib/features/quran/data/quran_repository.dart` — existing installs then re-seed their database automatically on next launch (bookmarks are kept).

### 2. Quran recitation audio

Download full-surah MP3s from [quranicaudio.com](https://quranicaudio.com) or per-ayah files from [everyayah.com](https://everyayah.com):

```bash
# Example: download all surahs for Mishary Alafasy via wget
mkdir -p ~/HalalAudio/Quran/MisharyAlafasy
for i in $(seq -w 1 114); do
  wget -q "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${i}.mp3" \
       -O ~/HalalAudio/Quran/MisharyAlafasy/${i}.mp3
done
```

#### In-app downloads (catalog)

The app also ships a download catalog, `assets/catalog/catalog.json`, listing full-surah MP3s it can fetch on request (a Downloads screen is being added). Nothing is downloaded unless you ask for it; files are stored under the app's data folder in `audio/<pack id>/` and resume after an interruption.

| Pack | Reciter | Source page |
|---|---|---|
| `qa-alafasy` | Mishari Rashid al-Afasy | [quranicaudio.com/quran/5](https://quranicaudio.com/quran/5) |
| `qa-abdulbaset-murattal` | AbdulBaset AbdulSamad (Murattal) | [quranicaudio.com/quran/37](https://quranicaudio.com/quran/37) |
| `qa-husary` | Mahmoud Khaleel Al-Husary | [quranicaudio.com/quran/16](https://quranicaudio.com/quran/16) |
| `qa-minshawi` | Muhammad Siddiq al-Minshawi | [quranicaudio.com/quran/6](https://quranicaudio.com/quran/6) |
| `qa-sudais` | Abdur-Rahman as-Sudais | [quranicaudio.com/quran/7](https://quranicaudio.com/quran/7) |

**Attribution and terms.** All audio in the catalog is downloaded directly from [QuranicAudio.com](https://quranicaudio.com) (`download.quranicaudio.com`), whose [About page](https://quranicaudio.com/about) states: *"Mp3s on this site may be downloaded and used for personal use free of charge. However, you may not use these files for commercial purposes as many of these files have rules and regulations that prevent their sale except by the publishing companies."* The same note is stored in each pack's `licenceNote`. Every URL in the catalog was checked (HTTP 200, `audio/mpeg`) when the catalog was built on 2026-11-13; `sizeBytes` is the size the server reported then, and a download whose size differs is rejected.

### 3. Arabic font (bundled)

Quran text is rendered with **Amiri Quran** (`assets/fonts/AmiriQuran-Regular.ttf`, family `Amiri Quran` in `pubspec.yaml`), © 2010–2022 The Amiri Project Authors, from [github.com/google/fonts](https://github.com/google/fonts/tree/main/ofl/amiriquran) (upstream: [aliftype/amiri](https://github.com/aliftype/amiri)). It is licensed under the SIL Open Font License 1.1 — see `assets/fonts/AmiriQuran-OFL.txt`.

### 4. Audio library folder structure

Place audio files anywhere; the app lets you pick the root folder at runtime. The recommended layout maps to auto-detected track types:

```
~/HalalAudio/
  Quran/
    MisharyAlafasy/       ← artist name becomes "artist" field
      001.mp3
      002.mp3
  Adhkar/
    morning_playlist/
  Nasheeds/
  WhiteNoise/
```

Sub-folder detection rules:

| Folder name contains | Detected type |
|---|---|
| `quran` | Quran |
| `adhkar`, `dhikr`, `azkar` | Adhkar |
| `noise`, `ambient`, `white` | White Noise |
| anything else | Nasheed |

Open the app → Library tab → **Scan Folder** → select `~/HalalAudio`.

---

## Keyboard shortcuts

| Key | Action |
|---|---|
| `Space` | Play / pause |
| `←` | Seek back 10 s |
| `→` | Seek forward 10 s |
| `N` | Next track |
| `S` | Toggle shuffle |

Shortcuts are suppressed when a text field has focus.

---

## Data locations

| Platform | Path |
|---|---|
| Linux | `~/.local/share/deen_audio/` |
| macOS | `~/Library/Application Support/deen_audio/` |
| Windows | `%APPDATA%\deen_audio\` |

The SQLite database `deen_audio.sqlite` lives here and holds the Quran text, the library index, bookmarks, last-read position, the library folder and all settings. Files left by older versions (`deen_audio.isar` and the per-setting `.txt`/`.json` files) are deleted once, on the first launch of the SQLite build.
