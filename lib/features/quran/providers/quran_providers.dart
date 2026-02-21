import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/bookmark.dart';
import '../../../core/models/surah.dart';
import '../data/quran_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

/// Central repository for all Quran CRUD operations.
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(ref.watch(isarProvider));
});

// ── Seeding ───────────────────────────────────────────────────────────────────

/// Seeds the database from bundled JSON on first launch.
/// Subsequent calls return instantly (isSeeded guard).
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

/// Whether to show English translations beneath each ayah.
final showTranslationProvider = StateProvider<bool>((ref) => true);

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

/// Last-read position loaded from disk at startup.
final lastReadProvider = FutureProvider<({int surah, int ayah})>((ref) {
  return ref.watch(quranRepositoryProvider).getLastRead();
});
