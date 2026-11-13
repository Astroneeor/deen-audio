import 'package:deen_audio/features/adhkar/data/adhkar_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Structural checks only. Whether each text and reference is *authentic*
/// has to be verified by a person against Hisnul Muslim — a test cannot.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = AdhkarRepository();

  final arabicLetters = RegExp(r'[ء-ي]');
  final latinLetters = RegExp(r'[A-Za-z]');

  for (final (name, load) in [
    ('morning', repo.loadMorning),
    ('evening', repo.loadEvening),
  ]) {
    group('$name adhkar', () {
      late List<Dhikr> adhkar;
      setUpAll(() async => adhkar = await load());

      test('every entry parses', () {
        expect(adhkar, isNotEmpty);
      });

      test('ids are unique and positive', () {
        final ids = adhkar.map((d) => d.id).toList();
        expect(ids.toSet(), hasLength(ids.length));
        expect(ids.every((id) => id > 0), isTrue);
      });

      test('every entry has a title, Arabic text and a count of at least 1',
          () {
        for (final d in adhkar) {
          expect(d.title.trim(), isNotEmpty, reason: 'id ${d.id}');
          expect(arabicLetters.hasMatch(d.arabic), isTrue,
              reason: 'id ${d.id} arabic');
          expect(latinLetters.hasMatch(d.arabic), isFalse,
              reason: 'id ${d.id} has Latin letters in the Arabic field');
          expect(d.count, greaterThanOrEqualTo(1), reason: 'id ${d.id}');
        }
      });

      test('optional fields are either absent or non-empty', () {
        for (final d in adhkar) {
          for (final field in [d.transliteration, d.translation, d.reference]) {
            expect(field == null || field.trim().isNotEmpty, isTrue,
                reason: 'id ${d.id}');
          }
        }
      });
    });
  }
}
