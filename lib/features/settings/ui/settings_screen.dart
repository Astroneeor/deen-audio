import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/library/providers/library_providers.dart';
import '../providers/settings_providers.dart';
import 'font_size_tile.dart';

/// Settings screen — library folder, prayer location, Quran font size, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Settings'),
          const SizedBox(height: 28),

          // ── Library ─────────────────────────────────────────────────────────
          _section('Library', [_LibraryFolderTile()]),
          const SizedBox(height: 24),

          // ── Prayer ──────────────────────────────────────────────────────────
          _section('Prayer Times', [const _LocationTile()]),
          const SizedBox(height: 24),

          // ── Quran ───────────────────────────────────────────────────────────
          _section('Quran', [const FontSizeTile()]),
          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────────────
          _section('About', [
            _infoTile('Version', '0.1.0'),
            _infoTile('Build', 'Phase 5 — Pre-release'),
            _infoTile('Framework', 'Flutter 3 · Isar · Riverpod'),
          ]),
        ],
      ),
    );
  }

  Widget _heading(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 16,
                      endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Library folder tile ───────────────────────────────────────────────────────

class _LibraryFolderTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanNotifierProvider);
    final folder = scanState.valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined,
              color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Library folder',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
                Text(
                  folder != null
                      ? folder.split('/').last
                      : 'No folder selected',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: scanState.isLoading
                ? null
                : () =>
                    ref.read(scanNotifierProvider.notifier).pickAndScan(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
            child: Text(folder != null ? 'Rescan' : 'Choose folder'),
          ),
        ],
      ),
    );
  }
}

// ── Location tile ─────────────────────────────────────────────────────────────

class _LocationTile extends ConsumerStatefulWidget {
  const _LocationTile();

  @override
  ConsumerState<_LocationTile> createState() => _LocationTileState();
}

class _LocationTileState extends ConsumerState<_LocationTile> {
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  String? _error;

  static const _methods = [
    ('muslimWorldLeague', 'Muslim World League'),
    ('northAmerica', 'North America (ISNA)'),
    ('egyptian', 'Egyptian General Authority'),
    ('karachi', 'University of Islamic Sciences, Karachi'),
    ('ummAlQura', 'Umm al-Qura (Makkah)'),
    ('kuwait', 'Kuwait'),
    ('qatar', 'Qatar'),
    ('singapore', 'Singapore'),
    ('turkey', 'Turkey'),
  ];

  @override
  void initState() {
    super.initState();
    final loc = ref.read(locationSettingsProvider);
    _latCtrl = TextEditingController(
        text: loc.latitude?.toStringAsFixed(4) ?? '');
    _lngCtrl = TextEditingController(
        text: loc.longitude?.toStringAsFixed(4) ?? '');
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null ||
        lng == null ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      setState(
          () => _error = 'Enter valid coordinates (lat −90–90, lng −180–180)');
      return;
    }
    setState(() => _error = null);
    ref.read(locationSettingsProvider.notifier).setLocation(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationSettingsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          const Row(children: [
            Icon(Icons.location_on_outlined,
                color: AppColors.textSecondary, size: 18),
            SizedBox(width: 12),
            Text('Prayer location',
                style:
                    TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ]),
          const SizedBox(height: 10),

          // Lat / Lng inputs + Save
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _coordField('Latitude', _latCtrl, '21.3891')),
            const SizedBox(width: 10),
            Expanded(child: _coordField('Longitude', _lngCtrl, '39.8579')),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.background,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Save'),
              ),
            ),
          ]),

          if (_error != null) ...[
            const SizedBox(height: 4),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 11)),
          ],

          const SizedBox(height: 10),
          // Calculation method dropdown
          Row(children: [
            const Text('Method:',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: loc.calculationMethod,
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
              underline: const SizedBox(),
              onChanged: (v) {
                if (v != null) {
                  ref
                      .read(locationSettingsProvider.notifier)
                      .setMethod(v);
                }
              },
              items: _methods
                  .map((m) => DropdownMenuItem(
                      value: m.$1,
                      child: Text(m.$2)))
                  .toList(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _coordField(
      String label, TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textMuted, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}
