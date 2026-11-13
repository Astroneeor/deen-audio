import 'dart:developer' as developer;

import 'catalog.dart';

/// Called once a file is verified and in place (relative store path).
typedef FileDoneCallback =
    void Function(CatalogPack pack, CatalogFile file, String relativePath);

/// Which of the given catalog file ids already have a Library track.
typedef RegisteredFilesQuery =
    Future<Set<String>> Function(Iterable<String> fileIds);

/// Runs a caller-supplied callback; a throw is logged, never propagated into
/// the download service.
void runLogged(void Function() callback) {
  try {
    callback();
  } catch (e, st) {
    developer.log(
      'Callback failed',
      name: 'downloads',
      error: e,
      stackTrace: st,
    );
  }
}

/// Calls [onDone] again for the finished reciter files among [doneIds] that
/// [registered] reports as having no Library track (e.g. adding it failed
/// when the download finished). Ids not in [catalog] are skipped; a failing
/// query is logged and nothing is called.
Future<void> reRegisterMissing(
  Iterable<String> doneIds,
  Catalog catalog,
  RegisteredFilesQuery? registered,
  FileDoneCallback? onDone, {
  required String Function(CatalogPack, CatalogFile) pathFor,
}) async {
  if (registered == null || onDone == null) return;
  final reciter = [
    for (final id in doneIds)
      if (catalog.packOfFile(id)?.kind == PackKind.quranReciter)
        catalog.requireFile(id),
  ];
  if (reciter.isEmpty) return;
  final Set<String> have;
  try {
    have = await registered(reciter.map((e) => e.$2.id));
  } catch (e, st) {
    developer.log(
      'Library lookup failed',
      name: 'downloads',
      error: e,
      stackTrace: st,
    );
    return;
  }
  for (final (pack, file) in reciter) {
    if (!have.contains(file.id)) {
      runLogged(() => onDone(pack, file, pathFor(pack, file)));
    }
  }
}
