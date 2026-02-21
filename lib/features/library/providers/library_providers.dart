import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/models/track.dart';
import '../data/library_repository.dart';
import '../data/library_scanner.dart';

// ── Core providers ────────────────────────────────────────────────────────────

/// Repository for all Track CRUD operations.
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(isarProvider));
});

/// Scanner that picks a folder and populates the repository.
final libraryScannerProvider = Provider<LibraryScanner>((ref) {
  return LibraryScanner(ref.watch(libraryRepositoryProvider));
});

// ── Track list providers ──────────────────────────────────────────────────────

/// Live stream of all tracks from Isar — updates automatically on DB changes.
final tracksStreamProvider = StreamProvider<List<Track>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchAllTracks();
});

/// Currently selected type filter.  null = show all types.
final trackTypeFilterProvider = StateProvider<TrackType?>((ref) => null);

/// Filtered track list derived from [tracksStreamProvider] + [trackTypeFilterProvider].
/// Returns the same [AsyncValue] shape so widgets can use .when() uniformly.
final filteredTracksProvider = Provider<AsyncValue<List<Track>>>((ref) {
  final all = ref.watch(tracksStreamProvider);
  final filter = ref.watch(trackTypeFilterProvider);
  if (filter == null) return all;
  return all.whenData(
    (tracks) => tracks.where((t) => t.type == filter).toList(),
  );
});

// ── Scan state ────────────────────────────────────────────────────────────────

class ScanNotifier extends StateNotifier<AsyncValue<String?>> {
  final LibraryScanner _scanner;

  ScanNotifier(this._scanner) : super(const AsyncData(null)) {
    _restoreLastFolder();
  }

  /// Restore the last-used folder path on startup (for display; tracks come from Isar).
  Future<void> _restoreLastFolder() async {
    final last = await _scanner.getLastFolder();
    if (last != null && mounted) state = AsyncData(last);
  }

  /// Open the OS directory picker, scan, and save.
  Future<void> pickAndScan() async {
    state = const AsyncLoading();
    try {
      final picked = await _scanner.pickAndScan();
      state = AsyncData(picked); // null if user cancelled
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Re-scan the previously used folder (no picker needed).
  Future<void> rescan() async {
    final folder = state.valueOrNull;
    if (folder == null) {
      await pickAndScan();
      return;
    }
    state = const AsyncLoading();
    try {
      await _scanner.scanPath(folder);
      state = AsyncData(folder);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final scanNotifierProvider =
    StateNotifierProvider<ScanNotifier, AsyncValue<String?>>((ref) {
  return ScanNotifier(ref.watch(libraryScannerProvider));
});

// ── TrackType display helpers ─────────────────────────────────────────────────

extension TrackTypeX on TrackType {
  String get label => switch (this) {
        TrackType.quran => 'Quran',
        TrackType.adhkar => 'Adhkar',
        TrackType.nasheed => 'Nasheeds',
        TrackType.whiteNoise => 'White Noise',
      };

  IconData get icon => switch (this) {
        TrackType.quran => Icons.menu_book_outlined,
        TrackType.adhkar => Icons.auto_awesome_outlined,
        TrackType.nasheed => Icons.music_note_outlined,
        TrackType.whiteNoise => Icons.waves_outlined,
      };
}
