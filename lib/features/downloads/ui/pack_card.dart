import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/catalog.dart';
import '../providers/download_actions.dart';
import '../providers/download_providers.dart';
import '../providers/pack_view.dart';
import 'pack_files_sheet.dart';
import 'pack_menu.dart';

/// What a pack's files are called: surahs for a reciter, files otherwise.
String packUnit(CatalogPack pack) =>
    pack.kind == PackKind.quranReciter ? 'surahs' : 'files';

/// One catalog pack: title, source, progress and the actions that fit its
/// state (see [packViewOf]), plus file choice and a menu.
class PackCard extends ConsumerWidget {
  final CatalogPack pack;

  const PackCard({super.key, required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(packProgressProvider(pack.id));
    final view = ref.watch(packViewProvider(pack.id));
    final failure = view.failure;
    final started = ref.watch(packItemsProvider(pack.id)).isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Titles(pack: pack)),
              PackMenu(pack: pack, hasDownloads: started),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (started) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.total == 0
                        ? 0
                        : progress.done / progress.total,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.gold,
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${progress.done} of ${progress.total} ${packUnit(pack)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (failure != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Failed: $failure',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final (i, action) in view.actions.indexed)
                      _actionButton(ref, action, primary: i == 0),
                    TextButton(
                      onPressed: () => showPackFiles(context, pack),
                      child: Text('Choose ${packUnit(pack)}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The main action is filled; any further one (Download all) is a text
  /// button, like Choose surahs.
  Widget _actionButton(
    WidgetRef ref,
    PackAction action, {
    required bool primary,
  }) {
    final actions = ref.read(downloadActionsProvider);
    final id = pack.id;
    final (label, onPressed) = switch (action) {
      PackAction.pause => ('Pause', () => actions.pausePack(id)),
      PackAction.retry => ('Retry', () => actions.resumePack(id)),
      PackAction.resume => ('Resume', () => actions.resumePack(id)),
      PackAction.downloadAll => ('Download all', () => actions.downloadPack(id)),
    };
    return primary
        ? ElevatedButton(onPressed: onPressed, child: Text(label))
        : TextButton(onPressed: onPressed, child: Text(label));
  }
}

class _Titles extends StatelessWidget {
  final CatalogPack pack;

  const _Titles({required this.pack});

  @override
  Widget build(BuildContext context) {
    final subtitle = [?pack.subtitle, pack.sourceName].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pack.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
