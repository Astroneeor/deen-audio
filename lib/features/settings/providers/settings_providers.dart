import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ── Quran font size ───────────────────────────────────────────────────────────

/// Persisted Quran body font size.  Default 26.  Range 18–48.
class QuranFontSizeNotifier extends StateNotifier<double> {
  static const _defaultSize = 26.0;
  static const _fileName = 'quran_font_size.txt';

  QuranFontSizeNotifier() : super(_defaultSize) {
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final val = double.tryParse(file.readAsStringSync().trim());
      if (val != null && val >= 18 && val <= 48) {
        state = val;
      }
    } catch (_) {}
  }

  Future<void> set(double size) async {
    state = size.clamp(18, 48).toDouble();
    try {
      final file = await _file();
      await file.writeAsString('${state.toStringAsFixed(1)}');
    } catch (_) {}
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}

/// Quran body font size — persisted across restarts.
final quranFontSizeProvider =
    StateNotifierProvider<QuranFontSizeNotifier, double>(
  (ref) => QuranFontSizeNotifier(),
);

// ── Prayer location ───────────────────────────────────────────────────────────

/// Persisted location and calculation method for prayer times.
class LocationSettings {
  final double? latitude;
  final double? longitude;
  final String calculationMethod;

  const LocationSettings({
    this.latitude,
    this.longitude,
    this.calculationMethod = 'muslimWorldLeague',
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'calculationMethod': calculationMethod,
      };

  factory LocationSettings.fromJson(Map<String, dynamic> m) =>
      LocationSettings(
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        calculationMethod:
            (m['calculationMethod'] as String?) ?? 'muslimWorldLeague',
      );
}

class LocationNotifier extends StateNotifier<LocationSettings> {
  static const _fileName = 'prayer_location.json';

  LocationNotifier() : super(const LocationSettings()) {
    _load();
  }

  Future<void> setLocation(double lat, double lng) async {
    state = LocationSettings(
      latitude: lat,
      longitude: lng,
      calculationMethod: state.calculationMethod,
    );
    await _save();
  }

  Future<void> setMethod(String method) async {
    state = LocationSettings(
      latitude: state.latitude,
      longitude: state.longitude,
      calculationMethod: method,
    );
    await _save();
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      state = LocationSettings.fromJson(decoded);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}

/// Prayer location + calculation method — persisted across restarts.
final locationSettingsProvider =
    StateNotifierProvider<LocationNotifier, LocationSettings>(
  (ref) => LocationNotifier(),
);
