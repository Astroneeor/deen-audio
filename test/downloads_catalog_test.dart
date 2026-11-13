// Catalog parsing: the test fixture, validation errors, the bundled catalog.
import 'dart:convert';
import 'dart:io';

import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/catalog_loader.dart';
import 'package:flutter_test/flutter_test.dart';

String fixture() =>
    File('test/fixtures/catalog_fixture.json').readAsStringSync();

/// The fixture with [edit] applied to its decoded JSON.
String editedFixture(void Function(Map<String, dynamic> json) edit) {
  final json = jsonDecode(fixture()) as Map<String, dynamic>;
  edit(json);
  return jsonEncode(json);
}

Map<String, dynamic> firstFile(Map<String, dynamic> json) =>
    ((json['packs'] as List).first['files'] as List).first
        as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the fixture parses into packs and files', () {
    final c = Catalog.parse(fixture());
    expect(c.packs.map((p) => p.id), ['test-reciter', 'test-scans']);

    final reciter = c.packs.first;
    expect(reciter.kind, PackKind.quranReciter);
    expect(reciter.subtitle, 'Murattal');
    expect(reciter.sourceName, 'Example Source');
    expect(reciter.sourceUrl, 'https://example.com/reciter');
    expect(reciter.licenceNote, 'Test data only.');
    final f = reciter.files.first;
    expect(f.id, 'test-reciter-001');
    expect(f.url, Uri.parse('https://example.com/audio/001.mp3'));
    expect(f.sizeBytes, 8);
    expect(f.surahNumber, 1);
    expect(f.fileName, '001.mp3');
    expect(reciter.files[1].checksumAlgo, 'sha256');

    final scans = c.packs.last;
    expect(scans.kind, PackKind.adhkarScans);
    expect(scans.licenceNote, isNull);
    expect(scans.files.first.surahNumber, isNull);

    expect(c.pack('test-scans'), same(scans));
    expect(c.file('test-reciter-001'), same(f));
    expect(c.packOfFile('test-scans-booklet'), same(scans));
    expect(c.file('missing'), isNull);
  });

  test('a duplicate file id throws FormatException', () {
    final json = editedFixture((j) {
      final packs = j['packs'] as List;
      (packs.last['files'] as List).first['id'] = 'test-reciter-001';
    });
    expect(() => Catalog.parse(json), throwsFormatException);
  });

  test('a duplicate pack id throws FormatException', () {
    final json = editedFixture((j) {
      final packs = j['packs'] as List;
      packs.last['id'] = 'test-reciter';
    });
    expect(() => Catalog.parse(json), throwsFormatException);
  });

  test('surah 115 in a quranReciter pack throws FormatException', () {
    final json = editedFixture((j) => firstFile(j)['surahNumber'] = 115);
    expect(() => Catalog.parse(json), throwsFormatException);
  });

  test('a quranReciter file without a surah number throws', () {
    final json = editedFixture((j) => firstFile(j).remove('surahNumber'));
    expect(() => Catalog.parse(json), throwsFormatException);
  });

  test('an ftp:// URL throws FormatException', () {
    final json = editedFixture(
      (j) => firstFile(j)['url'] = 'ftp://example.com/audio/001.mp3',
    );
    expect(() => Catalog.parse(json), throwsFormatException);
  });

  test('an unknown kind or a file name with a path throws', () {
    expect(
      () => Catalog.parse(
        editedFixture((j) => (j['packs'] as List).first['kind'] = 'x'),
      ),
      throwsFormatException,
    );
    expect(
      () => Catalog.parse(
        editedFixture((j) => firstFile(j)['fileName'] = '../001.mp3'),
      ),
      throwsFormatException,
    );
  });

  group('bundled assets/catalog/catalog.json', () {
    late Catalog bundled;
    setUpAll(
      () => bundled = Catalog.parse(
        File('assets/catalog/catalog.json').readAsStringSync(),
      ),
    );

    test('parses, holds only quranReciter packs with attribution', () {
      expect(bundled.packs, isNotEmpty);
      for (final p in bundled.packs) {
        expect(p.kind, PackKind.quranReciter, reason: p.id);
        expect(p.sourceName, isNotEmpty);
        expect(Uri.parse(p.sourceUrl).isScheme('https'), isTrue);
        expect(p.licenceNote, isNotEmpty, reason: p.id);
      }
    });

    test('every reciter pack has surahs 1..114 once each, all https', () {
      for (final p in bundled.packs) {
        expect(
          p.files.map((f) => f.surahNumber),
          List.generate(114, (i) => i + 1),
          reason: p.id,
        );
        for (final f in p.files) {
          expect(f.url.isScheme('https'), isTrue, reason: f.id);
          expect(f.sizeBytes, greaterThan(0), reason: f.id);
        }
      }
    });

    test('AssetCatalogLoader loads the same catalog from the bundle', () async {
      final loaded = await const AssetCatalogLoader().load();
      expect(loaded.packs.map((p) => p.id), bundled.packs.map((p) => p.id));
    });
  });
}
