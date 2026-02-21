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

- Flutter 3.13 or later (`flutter --version`)
- Dart SDK ≥ 3.0

### Linux

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev lld
```

`lld` is required when Flutter is installed via snap. Without it the linker step fails.

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

# 3. Generate Isar schema code (required after any model change)
flutter pub run build_runner build --delete-conflicting-outputs

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

The app ships with stub data. Replace the stubs with real content before use.

### 1. Full Quran text (required for Quran reader)

Download the Tanzil simple-clean JSON and the Saheeh International translation:

```
https://tanzil.net/download/
  → Quran text  : "Simple (with marked Quranic words)" → JSON
  → Translation : English → Saheeh International → JSON
```

Save the files as:

```
assets/quran/quran_simple.json
assets/quran/translation_en.json
```

Both files must use the array-of-surahs format the app expects:

```jsonc
// quran_simple.json
[
  {
    "number": 1,
    "name": "الفاتحة",
    "englishName": "Al-Faatiha",
    "englishNameTranslation": "The Opening",
    "numberOfAyahs": 7,
    "revelationType": "Meccan",
    "ayahs": [
      { "number": 1, "text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ" }
    ]
  }
]

// translation_en.json
[
  {
    "number": 1,
    "ayahs": [
      { "number": 1, "text": "In the name of Allah..." }
    ]
  }
]
```

After replacing the files, delete the Isar database so it re-seeds on next launch:

```bash
# Linux
rm -rf ~/.local/share/deen_audio/

# macOS
rm -rf ~/Library/Application\ Support/deen_audio/

# Windows (PowerShell)
Remove-Item -Recurse "$env:APPDATA\deen_audio"
```

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

### 3. Arabic font — Amiri (recommended)

```bash
# Linux
wget -O assets/fonts/Amiri-Regular.ttf \
  "https://github.com/aliftype/amiri/releases/latest/download/Amiri-Regular.ttf"

# macOS / Windows: download from https://amirifont.org and save to assets/fonts/Amiri-Regular.ttf
```

After placing the file, add the font declaration to `pubspec.yaml` under `flutter:`:

```yaml
flutter:
  fonts:
    - family: Amiri
      fonts:
        - asset: assets/fonts/Amiri-Regular.ttf
```

Then rebuild the app.

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

The Isar database, last-read Quran position, last library folder, and Quran font-size preference are all stored here.
