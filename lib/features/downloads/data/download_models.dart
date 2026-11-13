/// Where a requested download stands.
enum DownloadStatus { queued, running, paused, done, failed }

/// One catalog file the user asked to download (a `download_items` row).
class DownloadItem {
  const DownloadItem({
    required this.fileId,
    required this.packId,
    required this.status,
    required this.relativePath,
    this.bytesDone = 0,
    this.bytesTotal,
    this.error,
  });

  /// Catalog file id.
  final String fileId;
  final String packId;
  final DownloadStatus status;
  final int bytesDone;
  final int? bytesTotal;

  /// Human-readable reason when [status] is [DownloadStatus.failed].
  final String? error;

  /// Final file path, relative to the FileStore base directory.
  final String relativePath;

  /// 0.0–1.0, or null when the total size is unknown.
  double? get progress {
    final total = bytesTotal;
    if (status == DownloadStatus.done) return 1;
    if (total == null || total <= 0) return null;
    return (bytesDone / total).clamp(0.0, 1.0);
  }
}
