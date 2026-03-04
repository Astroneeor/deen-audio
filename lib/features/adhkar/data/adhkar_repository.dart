import 'dart:convert';

import 'package:flutter/services.dart';

/// A single dhikr (remembrance) entry from Hisnul Muslim.
class Dhikr {
  final int id;
  final String title;
  final String arabic;
  final String? transliteration;
  final String? translation; // optional — some sources are Arabic-only
  final int count;
  final String? reference;

  const Dhikr({
    required this.id,
    required this.title,
    required this.arabic,
    this.transliteration,
    this.translation,
    required this.count,
    this.reference,
  });

  factory Dhikr.fromJson(Map<String, dynamic> m) => Dhikr(
        id: (m['id'] as num?)?.toInt() ?? 0,
        title: m['title'] as String,
        arabic: m['arabic'] as String,
        transliteration: m['transliteration'] as String?,
        translation: m['translation'] as String?,
        count: (m['count'] as num?)?.toInt() ?? 1,
        reference: m['reference'] as String?,
      );
}

/// A single entry from azkar_obj.json (azkar-db library).
class AzkarEntry {
  final String category;
  final String arabic;
  final String? description;
  final int count;
  final String? reference;

  const AzkarEntry({
    required this.category,
    required this.arabic,
    this.description,
    required this.count,
    this.reference,
  });

  factory AzkarEntry.fromJson(Map<String, dynamic> m) => AzkarEntry(
        category: m['category'] as String,
        arabic: m['zekr'] as String,
        description: m['description'] as String?,
        count: _parseCount(m['count']),
        reference: m['reference'] as String?,
      );

  static int _parseCount(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String && value.isNotEmpty) return int.tryParse(value) ?? 1;
    return 1;
  }
}

/// A grouped category of azkar entries.
class AzkarCategory {
  final String name;
  final List<AzkarEntry> entries;

  const AzkarCategory({required this.name, required this.entries});
}

/// Loads adhkar from bundled JSON assets.
/// No Isar model needed — content is static and asset-based.
class AdhkarRepository {
  static const _morningAsset = 'assets/adhkar/morning.json';
  static const _eveningAsset = 'assets/adhkar/evening.json';
  static const _azkarObjAsset = 'assets/adhkar/azkar_obj.json';

  Future<List<Dhikr>> loadMorning() => _load(_morningAsset);
  Future<List<Dhikr>> loadEvening() => _load(_eveningAsset);

  /// Loads the full azkar-db dataset grouped by category.
  Future<List<AzkarCategory>> loadAllCategories() async {
    final raw = await rootBundle.loadString(_azkarObjAsset);
    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => AzkarEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    // Group by category, preserving order of first appearance
    final grouped = <String, List<AzkarEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    return grouped.entries
        .map((e) => AzkarCategory(name: e.key, entries: e.value))
        .toList();
  }

  Future<List<Dhikr>> _load(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Dhikr.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
