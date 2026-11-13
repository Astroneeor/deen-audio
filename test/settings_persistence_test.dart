import 'dart:io';

import 'package:deen_audio/features/settings/providers/settings_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/fake_path_provider.dart';

void main() {
  late Directory dir;
  File file(String name) => File(p.join(dir.path, name));

  setUp(() => dir = useTempAppSupportDir());

  group('Quran font size', () {
    test('loads the saved size', () async {
      file('quran_font_size.txt').writeAsStringSync('34.0\n');
      final n = QuranFontSizeNotifier();
      await n.loaded;
      expect(n.state, 34.0);
    });

    test('empty, corrupt or out-of-range files fall back to the default',
        () async {
      for (final content in ['', '   ', 'abc', '9000', 'NaN', '-3']) {
        file('quran_font_size.txt').writeAsStringSync(content);
        final n = QuranFontSizeNotifier();
        await n.loaded;
        expect(n.state, 26.0, reason: 'content "$content"');
      }
    });

    test('a change made before the saved value has loaded is not undone',
        () async {
      file('quran_font_size.txt').writeAsStringSync('30.0');
      final n = QuranFontSizeNotifier();
      // e.g. slider touched while the file is still being read
      final saved = n.set(40);
      await n.loaded;
      await saved;
      expect(n.state, 40.0);
      expect(file('quran_font_size.txt').readAsStringSync(), '40.0');
    });

    test('dragging the slider (many rapid writes) persists the final value',
        () async {
      final n = QuranFontSizeNotifier();
      await n.loaded;
      for (var i = 0; i < 300; i++) {
        n.set(18 + (i % 31).toDouble());
      }
      await n.set(33);
      expect(n.state, 33.0);
      expect(file('quran_font_size.txt').readAsStringSync(), '33.0');
      expect(
          dir.listSync().map((e) => p.basename(e.path)), ['quran_font_size.txt'],
          reason: 'no temp files left behind');
    });
  });

  group('Prayer location', () {
    test('round-trips location and method', () async {
      final n = LocationNotifier();
      await n.loaded;
      await n.setLocation(21.3891, 39.8579);
      await n.setMethod('ummAlQura');

      final again = LocationNotifier();
      await again.loaded;
      expect(again.state.latitude, 21.3891);
      expect(again.state.longitude, 39.8579);
      expect(again.state.calculationMethod, 'ummAlQura');
    });

    test('empty or corrupt files fall back to "no location"', () async {
      for (final content in ['', '{', '[]', '"x"', '{"latitude":"north"}']) {
        file('prayer_location.json').writeAsStringSync(content);
        final n = LocationNotifier();
        await n.loaded;
        expect(n.state.hasLocation, isFalse, reason: 'content "$content"');
        expect(n.state.calculationMethod, 'muslimWorldLeague');
      }
    });

    test('an unknown calculation method in the file is replaced by the default',
        () async {
      file('prayer_location.json').writeAsStringSync(
          '{"latitude":1.0,"longitude":2.0,"calculationMethod":"bogus"}');
      final n = LocationNotifier();
      await n.loaded;
      expect(n.state.hasLocation, isTrue);
      expect(n.state.calculationMethod, 'muslimWorldLeague',
          reason: 'the settings dropdown asserts on values it does not list');
    });

    test('out-of-range coordinates in the file are discarded', () async {
      file('prayer_location.json')
          .writeAsStringSync('{"latitude":500,"longitude":2.0}');
      final n = LocationNotifier();
      await n.loaded;
      expect(n.state.hasLocation, isFalse);
    });

    test('a change made before the saved value has loaded is not undone',
        () async {
      file('prayer_location.json').writeAsStringSync(
          '{"latitude":1.0,"longitude":2.0,"calculationMethod":"turkey"}');
      final n = LocationNotifier();
      final saved = n.setLocation(10, 20);
      await n.loaded;
      await saved;
      expect(n.state.latitude, 10);
      expect(n.state.longitude, 20);
    });
  });
}
