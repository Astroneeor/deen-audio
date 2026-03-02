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

/// Loads adhkar from bundled JSON assets.
/// No Isar model needed — content is static and asset-based.
class AdhkarRepository {
  static const _morningAsset = 'assets/adhkar/morning.json';
  static const _eveningAsset = 'assets/adhkar/evening.json';

  Future<List<Dhikr>> loadMorning() => _load(_morningAsset);
  Future<List<Dhikr>> loadEvening() => _load(_eveningAsset);

  Future<List<Dhikr>> _load(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Dhikr.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
