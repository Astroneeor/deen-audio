import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/settings_providers.dart';

/// Settings tile: prayer location (latitude / longitude) and the prayer-time
/// calculation method.
class LocationTile extends ConsumerStatefulWidget {
  const LocationTile({super.key});

  @override
  ConsumerState<LocationTile> createState() => _LocationTileState();
}

class _LocationTileState extends ConsumerState<LocationTile> {
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _showSaved(ref.read(locationSettingsProvider));
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  /// Puts the saved coordinates into the fields, leaving a field alone when
  /// it already holds that value (so saving never reformats what was typed).
  void _showSaved(LocationSettings loc) {
    void sync(TextEditingController ctrl, double? saved) {
      if (saved != null && double.tryParse(ctrl.text.trim()) != saved) {
        ctrl.text = saved.toString();
      }
    }

    sync(_latCtrl, loc.latitude);
    sync(_lngCtrl, loc.longitude);
  }

  void _save() {
    final coords =
        LocationSettings.parseCoordinates(_latCtrl.text, _lngCtrl.text);
    setState(() {
      _error = coords == null
          ? 'Enter valid coordinates (lat −90–90, lng −180–180)'
          : null;
    });
    if (coords == null) return;
    ref
        .read(locationSettingsProvider.notifier)
        .setLocation(coords.latitude, coords.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationSettingsProvider);

    // The saved location is read from disk asynchronously, so it can arrive
    // after this tile was first built with empty fields.
    ref.listen(locationSettingsProvider, (previous, next) {
      if (previous?.latitude != next.latitude ||
          previous?.longitude != next.longitude) {
        _showSaved(next);
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(children: [
            const Text('Method:',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 10),
            Flexible(
              child: DropdownButton<String>(
                value: loc.calculationMethod,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                underline: const SizedBox(),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(locationSettingsProvider.notifier).setMethod(v);
                  }
                },
                items: [
                  for (final m in prayerCalculationMethods.entries)
                    DropdownMenuItem(
                      value: m.key,
                      child: Text(m.value, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
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
