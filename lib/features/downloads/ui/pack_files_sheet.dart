import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/catalog.dart';
import '../data/download_models.dart';
import '../providers/download_actions.dart';
import '../providers/download_providers.dart';
import 'pack_card.dart';

/// Opens the per-file list of [pack] ("Choose surahs"): each file with its
/// state and the action that fits it.
Future<void> showPackFiles(BuildContext context, CatalogPack pack) =>
    showDialog<void>(
      context: context,
      builder: (_) => _PackFilesSheet(pack: pack),
    );

class _PackFilesSheet extends ConsumerWidget {
  final CatalogPack pack;

  const _PackFilesSheet({required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = {
      for (final i in ref.watch(packItemsProvider(pack.id))) i.fileId: i,
    };
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${pack.title} — choose ${packUnit(pack)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (pack.licenceNote != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  pack.licenceNote!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            const Divider(height: 1, color: AppColors.divider),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pack.files.length,
                itemBuilder: (_, i) => _FileRow(
                  file: pack.files[i],
                  item: items[pack.files[i].id],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends ConsumerWidget {
  final CatalogFile file;
  final DownloadItem? item;

  const _FileRow({required this.file, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(downloadActionsProvider);
    final status = item?.status;
    final failed = status == DownloadStatus.failed;
    final active =
        status == DownloadStatus.queued || status == DownloadStatus.running;

    IconButton button(String verb, IconData icon, VoidCallback onPressed) =>
        IconButton(
          tooltip: '$verb ${file.title}',
          icon: Icon(icon, size: 20),
          color: verb == 'Delete' ? AppColors.textMuted : AppColors.gold,
          onPressed: onPressed,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                if (active) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: item!.progress,
                    minHeight: 3,
                    color: AppColors.gold,
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ] else
                  Text(
                    _statusText(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: failed ? AppColors.error : AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ...switch (status) {
            null => [
              button('Download', Icons.download, () {
                actions.downloadFile(file.id);
              }),
            ],
            DownloadStatus.queued || DownloadStatus.running => [
              button('Pause', Icons.pause, () => actions.pauseFile(file.id)),
            ],
            DownloadStatus.paused || DownloadStatus.failed => [
              button(failed ? 'Retry' : 'Resume', Icons.refresh, () {
                actions.resumeFile(file.id);
              }),
              button('Delete', Icons.delete_outline, () {
                actions.deleteFile(file.id);
              }),
            ],
            DownloadStatus.done => [
              button('Delete', Icons.delete_outline, () {
                actions.deleteFile(file.id);
              }),
            ],
          },
        ],
      ),
    );
  }
}

String _statusText(DownloadItem? item) => switch (item?.status) {
  null => 'Not downloaded',
  DownloadStatus.paused => 'Paused',
  DownloadStatus.failed => item!.error ?? 'Failed',
  DownloadStatus.done => 'Downloaded',
  DownloadStatus.queued || DownloadStatus.running => 'Downloading',
};
