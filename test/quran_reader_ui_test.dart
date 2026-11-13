import 'package:deen_audio/core/models/ayah.dart';
import 'package:deen_audio/core/models/surah.dart';
import 'package:deen_audio/core/theme/app_fonts.dart';
import 'package:deen_audio/features/quran/data/quran_repository.dart';
import 'package:deen_audio/features/quran/providers/quran_providers.dart';
import 'package:deen_audio/features/quran/ui/ayah_reader.dart';
import 'package:deen_audio/features/quran/ui/surah_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements QuranRepository {
  final saved = <(int, int)>[];

  @override
  Future<void> saveLastRead(int surahNumber, int ayahNumber) async =>
      saved.add((surahNumber, ayahNumber));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Surah _surah(int n) => Surah()
  ..number = n
  ..name = 'سورة'
  ..englishName = 'Surah $n'
  ..englishNameTranslation = 'T$n'
  ..numberOfAyahs = 40
  ..revelationType = 'Meccan';

List<Ayah> _ayahs(int surah) => [
      for (var i = 1; i <= 40; i++)
        Ayah()
          ..surahNumber = surah
          ..ayahNumber = i
          ..arabicText = 'بسم الله'
          ..translation = 'Translation $i',
    ];

Future<_FakeRepo> _pump(WidgetTester tester, Widget child) async {
  final repo = _FakeRepo();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      quranRepositoryProvider.overrideWithValue(repo),
      surahsProvider.overrideWith((ref) => [_surah(1), _surah(2), _surah(3)]),
      currentAyahsProvider.overrideWith(
          (ref) => _ayahs(ref.watch(selectedSurahNumberProvider))),
      bookmarkedAyahsProvider.overrideWith((ref) => <int>{}),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  ));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('surah title uses the bundled Quran font, right-to-left',
      (tester) async {
    await _pump(tester, const AyahReader());
    final title = tester.widget<Text>(find.text('سورة'));
    expect(title.style?.fontFamily, AppFonts.quranText);
    expect(title.textDirection, TextDirection.rtl);
  });

  testWidgets('scrolling saves the position once it settles, not per frame',
      (tester) async {
    final repo = await _pump(tester, const AyahReader());

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(ListView)));
    for (var i = 0; i < 30; i++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(repo.saved, isNotEmpty);
    expect(repo.saved.length, lessThanOrEqualTo(3),
        reason: 'one file write per scroll frame floods the disk and lets '
            'writes land out of order');
    expect(repo.saved.last.$1, 1);
    expect(repo.saved.last.$2, greaterThan(1));
  });

  testWidgets('a pending position is still saved when leaving the reader',
      (tester) async {
    final repo = await _pump(tester, const AyahReader());
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 16));

    await tester.pumpWidget(const SizedBox());

    expect(repo.saved, isNotEmpty);
  });

  testWidgets('choosing a surah records it as the last-read position',
      (tester) async {
    final repo = await _pump(tester, const SurahList());

    await tester.tap(find.textContaining('Surah 2'));
    await tester.pump();

    expect(repo.saved, [(2, 1)]);
  });
}
