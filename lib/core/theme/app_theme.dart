import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        error: AppColors.error,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.background,
        surfaceContainerHighest: AppColors.surfaceVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 20,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.surfaceVariant,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.border),
        thickness: WidgetStatePropertyAll(4),
        radius: Radius.circular(2),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.gold,
        overlayColor: Color(0x22C9A84C),
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
