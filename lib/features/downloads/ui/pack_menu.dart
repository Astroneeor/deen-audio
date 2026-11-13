import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/catalog.dart';
import '../providers/download_actions.dart';
import 'confirm_delete.dart';

enum _MenuChoice { delete, copyLink, licence }

/// The ⋯ menu of a pack card: delete its downloads, copy the source page
/// link, and read the source's licence terms.
class PackMenu extends ConsumerWidget {
  final CatalogPack pack;

  /// Whether the pack has any rows to delete.
  final bool hasDownloads;

  const PackMenu({super.key, required this.pack, required this.hasDownloads});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_MenuChoice>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
      onSelected: (choice) => switch (choice) {
        _MenuChoice.delete => _confirmDelete(context, ref),
        _MenuChoice.copyLink => _copyLink(context),
        _MenuChoice.licence => showPackLicence(context, pack),
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _MenuChoice.delete,
          enabled: hasDownloads,
          child: const Text('Delete downloads'),
        ),
        const PopupMenuItem(
          value: _MenuChoice.copyLink,
          child: Text('Copy source page link'),
        ),
        const PopupMenuItem(
          value: _MenuChoice.licence,
          child: Text('Licence and source'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete downloads?',
      message:
          'Removes the downloaded files of ${pack.title} from this device. '
          'Their tracks leave the Library.',
    );
    if (ok) await ref.read(downloadActionsProvider).deletePack(pack.id);
  }

  Future<void> _copyLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: pack.sourceUrl));
    messenger?.showSnackBar(
      SnackBar(content: Text('Link copied: ${pack.sourceUrl}')),
    );
  }
}

/// Shows the pack's source and its stated terms of use.
Future<void> showPackLicence(BuildContext context, CatalogPack pack) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pack.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Source: ${pack.sourceName}'),
              const SizedBox(height: 4),
              SelectableText(
                pack.sourceUrl,
                style: const TextStyle(color: AppColors.gold, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                pack.licenceNote ?? 'The source has not stated its terms.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
