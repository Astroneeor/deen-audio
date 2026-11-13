import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/download_models.dart';
import 'download_providers.dart';

/// A pack-level action a pack card can offer.
enum PackAction { pause, retry, resume, downloadAll }

/// What a pack card shows besides its progress: its actions (main one first)
/// and the reason of its first failed file, if any.
typedef PackView = ({List<PackAction> actions, String? failure});

/// Maps a pack's rows to its card actions. At most one of Pause (something
/// queued or running) / Retry (something failed) / Resume (something paused)
/// comes first; Download all follows whenever some catalog file has no row
/// yet, since resuming never starts those.
PackView packViewOf({required int total, required List<DownloadItem> items}) {
  bool any(Set<DownloadStatus> s) => items.any((i) => s.contains(i.status));
  final failed = items.where((i) => i.status == DownloadStatus.failed);
  return (
    actions: [
      if (any({DownloadStatus.queued, DownloadStatus.running}))
        PackAction.pause
      else if (failed.isNotEmpty)
        PackAction.retry
      else if (any({DownloadStatus.paused}))
        PackAction.resume,
      if (items.length < total) PackAction.downloadAll,
    ],
    failure: failed.isEmpty ? null : failed.first.error ?? 'Unknown error',
  );
}

/// Provides the actions and failure reason shown on one pack's card.
final packViewProvider = Provider.family<PackView, String>(
  (ref, packId) => packViewOf(
    total: ref.watch(packProgressProvider(packId)).total,
    items: ref.watch(packItemsProvider(packId)),
  ),
);
