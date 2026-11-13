import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_file.dart';

// ── Quran font size ───────────────────────────────────────────────────────────

/// Persisted Quran body font size.  Default 26.  Range 18–48.
class QuranFontSizeNotifier extends StateNotifier<double> {
  static const defaultSize = 26.0;
  static const minSize = 18.0;
  static const maxSize = 48.0;

  final _file = SettingsFile('quran_font_size.txt');

  /// Set once the user changes the value; a still-running initial load must
  /// then not overwrite it with the older value from disk.
  bool _changed = false;

  /// Completes when the saved value has been read (or found missing).
  late final Future<void> loaded;

  QuranFontSizeNotifier() : super(defaultSize) {
    loaded = _load();
  }

  Future<void> _load() async {
    final raw = await _file.read();
    if (raw == null || !mounted || _changed) return;
    final val = double.tryParse(raw.trim());
    if (val != null && val >= minSize && val <= maxSize) state = val;
  }

  Future<void> set(double size) {
    _changed = true;
    state = size.clamp(minSize, maxSize).toDouble();
    return _file.write(state.toStringAsFixed(1));
  }
}

/// Quran body font size — persisted across restarts.
final quranFontSizeProvider =
    StateNotifierProvider<QuranFontSizeNotifier, double>(
  (ref) => QuranFontSizeNotifier(),
);

// ── Prayer location ───────────────────────────────────────────────────────────

/// Supported prayer-time calculation methods: persisted id → display name.
/// The single source of truth for the settings dropdown, for validating the
/// saved file, and for the prayer feature's mapping to adhan parameters.
const prayerCalculationMethods = <String, String>{
  'muslimWorldLeague': 'Muslim World League',
  'northAmerica': 'North America (ISNA)',
  'egyptian': 'Egyptian General Authority',
  'karachi': 'University of Islamic Sciences, Karachi',
  'ummAlQura': 'Umm al-Qura (Makkah)',
  'kuwait': 'Kuwait',
  'qatar': 'Qatar',
  'singapore': 'Singapore',
  'turkey': 'Turkey',
};

/// Persisted location and calculation method for prayer times.
class LocationSettings {
  static const defaultMethod = 'muslimWorldLeague';

  final double? latitude;
  final double? longitude;
  final String calculationMethod;

  const LocationSettings({
    this.latitude,
    this.longitude,
    this.calculationMethod = defaultMethod,
  });

  bool get hasLocation => latitude != null && longitude != null;

  /// Whether [lat] / [lng] are real coordinates in degrees.
  static bool isValidCoordinates(double? lat, double? lng) =>
      lat != null &&
      lng != null &&
      lat.isFinite &&
      lng.isFinite &&
      lat.abs() <= 90 &&
      lng.abs() <= 180;

  /// Parses what the user typed into the latitude / longitude fields.
  /// Returns null unless both are valid.
  static ({double latitude, double longitude})? parseCoordinates(
    String latText,
    String lngText,
  ) {
    final lat = double.tryParse(latText.trim());
    final lng = double.tryParse(lngText.trim());
    if (!isValidCoordinates(lat, lng)) return null;
    return (latitude: lat!, longitude: lng!);
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'calculationMethod': calculationMethod,
      };

  /// Tolerant of hand-edited or damaged files: anything that is not a valid
  /// coordinate pair / known method falls back to "not set" / the default.
  factory LocationSettings.fromJson(Map<String, dynamic> m) {
    final lat = m['latitude'];
    final lng = m['longitude'];
    final latitude = lat is num ? lat.toDouble() : null;
    final longitude = lng is num ? lng.toDouble() : null;
    final valid = isValidCoordinates(latitude, longitude);
    final method = m['calculationMethod'];
    return LocationSettings(
      latitude: valid ? latitude : null,
      longitude: valid ? longitude : null,
      calculationMethod: prayerCalculationMethods.containsKey(method)
          ? method as String
          : defaultMethod,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationSettings> {
  final _file = SettingsFile('prayer_location.json');

  /// See [QuranFontSizeNotifier._changed].
  bool _changed = false;

  /// Completes when the saved settings have been read (or found missing).
  late final Future<void> loaded;

  LocationNotifier() : super(const LocationSettings()) {
    loaded = _load();
  }

  Future<void> setLocation(double lat, double lng) {
    state = LocationSettings(
      latitude: lat,
      longitude: lng,
      calculationMethod: state.calculationMethod,
    );
    return _save();
  }

  Future<void> setMethod(String method) {
    state = LocationSettings(
      latitude: state.latitude,
      longitude: state.longitude,
      calculationMethod: method,
    );
    return _save();
  }

  Future<void> _load() async {
    final raw = await _file.read();
    if (raw == null || !mounted || _changed) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        state = LocationSettings.fromJson(decoded);
      }
    } on FormatException {
      // Empty or corrupt file: keep the defaults.
    }
  }

  Future<void> _save() {
    _changed = true;
    return _file.write(jsonEncode(state.toJson()));
  }
}

/// Prayer location + calculation method — persisted across restarts.
final locationSettingsProvider =
    StateNotifierProvider<LocationNotifier, LocationSettings>(
  (ref) => LocationNotifier(),
);
