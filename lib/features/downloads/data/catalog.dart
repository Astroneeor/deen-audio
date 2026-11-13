import 'dart:convert';

/// What a catalog pack contains.
enum PackKind {
  /// Full-surah recitation MP3s by one reciter (registered as Quran tracks).
  quranReciter,

  /// Scanned adhkar pages (images or PDF); not registered as tracks.
  adhkarScans,
}

/// One downloadable file of a [CatalogPack].
class CatalogFile {
  const CatalogFile({
    required this.id,
    required this.title,
    required this.url,
    required this.fileName,
    this.sizeBytes,
    this.checksum,
    this.checksumAlgo,
    this.surahNumber,
  });

  /// Globally unique; the `download_items` primary key.
  final String id;
  final String title;
  final Uri url;
  final int? sizeBytes;

  /// Hex digest of the whole file, checked when present.
  final String? checksum;

  /// One of [Catalog.checksumAlgos].
  final String? checksumAlgo;

  /// 1–114; required for [PackKind.quranReciter] files.
  final int? surahNumber;

  /// Plain file name (no directories) the file is saved under.
  final String fileName;
}

/// A downloadable set of files from one source, with its attribution.
class CatalogPack {
  const CatalogPack({
    required this.id,
    required this.kind,
    required this.title,
    required this.sourceName,
    required this.sourceUrl,
    required this.files,
    this.subtitle,
    this.licenceNote,
  });

  final String id;
  final PackKind kind;
  final String title;

  /// Style or riwayah, e.g. "Murattal".
  final String? subtitle;
  final String sourceName;

  /// The source's page for this pack, shown for attribution.
  final String sourceUrl;

  /// The source's stated terms, quoted or summarised.
  final String? licenceNote;
  final List<CatalogFile> files;
}

/// The download catalog: packs → files. Parsed from the bundled
/// `assets/catalog/catalog.json` (see [Catalog.parse] for the format).
class Catalog {
  Catalog(this.packs)
    : _files = {
        for (final p in packs)
          for (final f in p.files) f.id: (p, f),
      };

  static const checksumAlgos = {'sha256', 'sha1', 'md5'};

  final List<CatalogPack> packs;
  final Map<String, (CatalogPack, CatalogFile)> _files;

  CatalogPack? pack(String id) {
    for (final p in packs) {
      if (p.id == id) return p;
    }
    return null;
  }

  CatalogFile? file(String id) => _files[id]?.$2;

  CatalogPack? packOfFile(String fileId) => _files[fileId]?.$1;

  /// The pack and file for [fileId]; throws [ArgumentError] if unknown.
  (CatalogPack, CatalogFile) requireFile(String fileId) =>
      _files[fileId] ??
      (throw ArgumentError.value(fileId, 'fileId', 'not in the catalog'));

  /// The pack [packId]; throws [ArgumentError] if unknown.
  CatalogPack requirePack(String packId) =>
      pack(packId) ??
      (throw ArgumentError.value(packId, 'packId', 'not in the catalog'));

  /// Parses `{"packs": [{id, kind, title, subtitle?, sourceName, sourceUrl,
  /// licenceNote?, files: [{id, title, url, sizeBytes?, checksum?,
  /// checksumAlgo?, surahNumber?, fileName}]}]}`.
  ///
  /// Throws [FormatException] on a missing field, a duplicate pack or file
  /// id, a pack or file id that is not a safe path segment, a non-http(s) URL, a file name containing a path, an unknown kind or
  /// checksum algorithm, or a `quranReciter` file whose surah number is
  /// missing or outside 1–114.
  static Catalog parse(String json) {
    final root = jsonDecode(json);
    if (root is! Map<String, dynamic>) {
      throw const FormatException('Catalog root must be an object');
    }
    final packIds = <String>{};
    final fileIds = <String>{};
    final packs = <CatalogPack>[];
    for (final raw in _list(root, 'packs', 'catalog')) {
      final p = _map(raw, 'pack');
      final id = _id(p, 'pack');
      if (!packIds.add(id)) throw FormatException('Duplicate pack id "$id"');
      final kindName = _str(p, 'kind', id);
      final kind = PackKind.values.where((k) => k.name == kindName);
      if (kind.isEmpty) throw FormatException('Pack $id: unknown kind');
      final files = <CatalogFile>[];
      for (final rawFile in _list(p, 'files', id)) {
        final file = _parseFile(_map(rawFile, id), kind.single, id);
        if (!fileIds.add(file.id)) {
          throw FormatException('Duplicate file id "${file.id}"');
        }
        files.add(file);
      }
      packs.add(
        CatalogPack(
          id: id,
          kind: kind.single,
          title: _str(p, 'title', id),
          subtitle: _optStr(p, 'subtitle', id),
          sourceName: _str(p, 'sourceName', id),
          sourceUrl: _httpUrl(_str(p, 'sourceUrl', id), id).toString(),
          licenceNote: _optStr(p, 'licenceNote', id),
          files: List.unmodifiable(files),
        ),
      );
    }
    return Catalog(List.unmodifiable(packs));
  }

  static CatalogFile _parseFile(
    Map<String, dynamic> f,
    PackKind kind,
    String packId,
  ) {
    final id = _id(f, packId);
    final surah = f['surahNumber'];
    if (surah != null && surah is! int) {
      throw FormatException('File $id: surahNumber must be an integer');
    }
    if (kind == PackKind.quranReciter &&
        (surah == null || surah < 1 || surah > 114)) {
      throw FormatException('File $id: surahNumber must be 1–114');
    }
    final fileName = _str(f, 'fileName', id);
    if (fileName.contains('/') ||
        fileName.contains('\\') ||
        fileName == '.' ||
        fileName == '..') {
      throw FormatException('File $id: fileName must not contain a path');
    }
    final size = f['sizeBytes'];
    if (size != null && (size is! int || size <= 0)) {
      throw FormatException('File $id: sizeBytes must be a positive integer');
    }
    final checksum = _optStr(f, 'checksum', id);
    final algo = _optStr(f, 'checksumAlgo', id);
    if ((checksum == null) != (algo == null) ||
        (algo != null && !checksumAlgos.contains(algo))) {
      throw FormatException('File $id: checksum needs a known checksumAlgo');
    }
    return CatalogFile(
      id: id,
      title: _str(f, 'title', id),
      url: _httpUrl(_str(f, 'url', id), id),
      fileName: fileName,
      sizeBytes: size as int?,
      checksum: checksum?.toLowerCase(),
      checksumAlgo: algo,
      surahNumber: surah as int?,
    );
  }

  static Uri _httpUrl(String s, String where) {
    final uri = Uri.tryParse(s);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      throw FormatException('$where: "$s" is not an http(s) URL');
    }
    return uri;
  }

  static Map<String, dynamic> _map(Object? v, String where) =>
      v is Map<String, dynamic>
      ? v
      : throw FormatException('$where: expected an object');

  static List<Object?> _list(Map<String, dynamic> m, String key, String where) {
    final v = m[key];
    return v is List
        ? v
        : throw FormatException('$where: "$key" must be a list');
  }

  static String _str(Map<String, dynamic> m, String key, String where) {
    final v = m[key];
    if (v is String && v.trim().isNotEmpty) return v;
    throw FormatException('$where: "$key" must be a non-empty string');
  }

  static final _safeId = RegExp(r'^[A-Za-z0-9._-]+$');

  /// The `id` of [m]: becomes a directory or row key, so letters, digits and
  /// `. _ -` only, and never `.` or `..`.
  static String _id(Map<String, dynamic> m, String where) {
    final id = _str(m, 'id', where);
    if (!_safeId.hasMatch(id) || id == '.' || id == '..') {
      throw FormatException('$where: id "$id" is not a safe path segment');
    }
    return id;
  }

  static String? _optStr(Map<String, dynamic> m, String key, String where) =>
      m[key] == null ? null : _str(m, key, where);
}
