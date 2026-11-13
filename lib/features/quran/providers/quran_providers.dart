import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/settings_repository.dart';
import '../../../core/providers/foundation_providers.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/bookmark.dart';
import '../../../core/models/surah.dart';
import '../data/quran_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

/// Central repository for all Quran CRUD operations.
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncStamperProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(deviceSettingsRepositoryProvider),
  );
});

// ── Seeding ───────────────────────────────────────────────────────────────────

/// Seeds the database from the bundled Quran JSON on first launch, and
/// re-seeds installs that still hold the old stub or an outdated dataset.
/// JSON parsing runs on a background isolate and rows are written in small
/// chunks, so the UI stays responsive. Later launches return immediately.
final quranInitProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  if (!await repo.isSeeded()) {
    await repo.seed();
  }
});

// ── Surah list ────────────────────────────────────────────────────────────────

/// All surahs sorted by number.  Waits for seeding to complete first.
final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  await ref.watch(quranInitProvider.future);
  return ref.watch(quranRepositoryProvider).getAllSurahs();
});

// ── Selection state ───────────────────────────────────────────────────────────

/// Currently selected surah number (1-based). Defaults to 1 (Al-Fatiha).
final selectedSurahNumberProvider = StateProvider<int>((ref) => 1);

// ── Ayah list ─────────────────────────────────────────────────────────────────

/// Ayahs for the currently selected surah.
final currentAyahsProvider = FutureProvider<List<Ayah>>((ref) async {
  await ref.watch(quranInitProvider.future);
  final surahNumber = ref.watch(selectedSurahNumberProvider);
  return ref.watch(quranRepositoryProvider).getAyahs(surahNumber);
});

// ── Translation toggle ────────────────────────────────────────────────────────

/// Persisted "show translation" flag (settings key `quran.showTranslation`).
/// Default on. Like the font size, a change made before the saved value has
/// loaded wins over it, and persistence is best-effort.
class ShowTranslationNotifier extends StateNotifier<bool> {
  ShowTranslationNotifier(this._repo) : super(true) {
    loaded = _load();
  }

  static const settingsKey = 'quran.showTranslation';

  final SettingsRepository _repo;
  bool _changed = false;

  /// Completes when the saved value has been read (or found missing).
  late final Future<void> loaded;

  Future<void> _load() async {
    Object? raw;
    try {
      raw = await _repo.read(settingsKey);
    } catch (_) {
      return;
    }
    if (raw is bool && mounted && !_changed) state = raw;
  }

  Future<void> set(bool show) {
    _changed = true;
    state = show;
    return _repo.write(settingsKey, show).catchError((Object _) {});
  }
}

/// Whether to show English translations beneath each ayah (persisted).
final showTranslationProvider =
    StateNotifierProvider<ShowTranslationNotifier, bool>(
  (ref) => ShowTranslationNotifier(ref.watch(settingsRepositoryProvider)),
);

// ── Bookmarks ─────────────────────────────────────────────────────────────────

/// Live stream of all Quran bookmarks.
final bookmarksStreamProvider = StreamProvider<List<Bookmark>>((ref) {
  return ref.watch(quranRepositoryProvider).watchBookmarks();
});

/// Set of bookmarked ayah numbers within the currently selected surah.
final bookmarkedAyahsProvider = FutureProvider<Set<int>>((ref) async {
  // Re-evaluate when bookmarks change.
  ref.watch(bookmarksStreamProvider);
  final surahNumber = ref.watch(selectedSurahNumberProvider);
  return ref.watch(quranRepositoryProvider).getBookmarkedAyahNumbers(surahNumber);
});

// ── Last-read position ────────────────────────────────────────────────────────

/// Last-read position loaded from the database at startup (1:1 if none).
final lastReadProvider = FutureProvider<({int surah, int ayah})>((ref) async {
  final pos = await ref.watch(quranRepositoryProvider).getLastRead();
  return pos ?? (surah: 1, ayah: 1);
});
