import '../../../core/models/track.dart';
import '../../library/data/library_repository.dart';
import 'catalog.dart';

/// Adds the Library track for a finished download. Only Quran recitations
/// become tracks; adhkar scans are not audio and are skipped.
Future<void> registerDownloadedFile(
  LibraryRepository library,
  CatalogPack pack,
  CatalogFile file,
  String relativePath,
) async {
  if (pack.kind != PackKind.quranReciter) return;
  await library.upsertDownloadedTrack(
    catalogFileId: file.id,
    title: file.title,
    artist: pack.title,
    type: TrackType.quran,
    relativePath: relativePath,
    surahNumber: file.surahNumber?.toString(),
  );
}

/// Removes the Library track of a deleted download (a no-op when the file
/// never had one).
Future<void> unregisterDownloadedFile(
  LibraryRepository library,
  CatalogFile file,
) => library.removeDownloadedTrack(file.id);
