/// Font family name constants used throughout the app.
class AppFonts {
  AppFonts._();

  /// QCF (King Fahd Complex) Uthman Taha Naskh font for Quran text.
  ///
  /// To enable this font:
  ///   1. Download a TTF build of UthmanTN1 or UthmanicHafs1 from
  ///      https://github.com/mustafa0x/qpc-fonts
  ///   2. Save to assets/fonts/<filename>.ttf
  ///   3. Declare in pubspec.yaml under flutter → fonts
  ///
  /// Falls back to a system Arabic font when not installed.
  static const String quranText = 'KFGQPC Uthman Taha Naskh';
}
