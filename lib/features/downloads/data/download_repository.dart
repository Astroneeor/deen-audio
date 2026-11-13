import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'download_models.dart';

/// Reads and writes download state (`download_items`, device-local).
class DownloadRepository {
  DownloadRepository(this._db);

  final AppDatabase _db;

  // ── Reads ─────────────────────────────────────────────────────────────────

  Future<DownloadItem?> get(String fileId) async {
    final row = await (_db.select(
      _db.downloadItems,
    )..where((t) => t.fileId.equals(fileId))).getSingleOrNull();
    return row == null ? null : _toItem(row);
  }

  Future<List<DownloadItem>> getAll() async =>
      (await _all().get()).map(_toItem).toList();

  /// Live list of every download, ordered by pack then file id.
  Stream<List<DownloadItem>> watchAll() =>
      _all().watch().map((rows) => rows.map(_toItem).toList());

  /// Live list of one pack's downloads, ordered by file id.
  Stream<List<DownloadItem>> watchPack(String packId) =>
      (_all()..where((t) => t.packId.equals(packId))).watch().map(
        (rows) => rows.map(_toItem).toList(),
      );

  SimpleSelectStatement<$DownloadItemsTable, DownloadItemRow> _all() =>
      _db.select(_db.downloadItems)
        ..orderBy([(t) => OrderingTerm(expression: t.packId)])
        ..orderBy([(t) => OrderingTerm(expression: t.fileId)]);

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Inserts or replaces the row for [item].
  Future<void> upsert(
    DownloadItem item, {
    required Uri url,
    String? checksum,
  }) => _db
      .into(_db.downloadItems)
      .insertOnConflictUpdate(
        DownloadItemsCompanion.insert(
          fileId: item.fileId,
          packId: item.packId,
          url: url.toString(),
          relativePath: item.relativePath,
          bytesTotal: Value(item.bytesTotal),
          bytesDone: Value(item.bytesDone),
          status: item.status.name,
          error: Value(item.error),
          checksum: Value(checksum),
        ),
      );

  /// Sets the status; [error] is stored as given (null clears it).
  Future<void> setStatus(
    String fileId,
    DownloadStatus status, {
    String? error,
  }) => _update(
    fileId,
    DownloadItemsCompanion(status: Value(status.name), error: Value(error)),
  );

  Future<void> setProgress(String fileId, int bytesDone, {int? bytesTotal}) =>
      _update(
        fileId,
        DownloadItemsCompanion(
          bytesDone: Value(bytesDone),
          bytesTotal: bytesTotal == null
              ? const Value.absent()
              : Value(bytesTotal),
        ),
      );

  Future<void> delete(String fileId) => (_db.delete(
    _db.downloadItems,
  )..where((t) => t.fileId.equals(fileId))).go();

  /// After an app restart nothing is in flight: rows left `running` (and
  /// `queued`, whose in-memory queue is gone) become `paused`, so the user
  /// can resume them. Starts nothing.
  Future<void> pauseUnfinished() =>
      (_db.update(_db.downloadItems)..where(
            (t) => t.status.isIn([
              DownloadStatus.running.name,
              DownloadStatus.queued.name,
            ]),
          ))
          .write(
            DownloadItemsCompanion(status: Value(DownloadStatus.paused.name)),
          );

  Future<void> _update(String fileId, DownloadItemsCompanion values) =>
      (_db.update(
        _db.downloadItems,
      )..where((t) => t.fileId.equals(fileId))).write(values);

  DownloadItem _toItem(DownloadItemRow r) => DownloadItem(
    fileId: r.fileId,
    packId: r.packId,
    status: DownloadStatus.values.byName(r.status),
    bytesDone: r.bytesDone,
    bytesTotal: r.bytesTotal,
    error: r.error,
    relativePath: r.relativePath,
  );
}
