import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const List<String> fontFallbacks = ['Plus Jakarta Sans', 'Inter', 'Roboto', 'sans-serif'];

  static ThemeData get lightTheme {
    const defaultTextTheme = Typography.blackMountainView;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Plus Jakarta Sans',
      fontFamilyFallback: fontFallbacks,
      primaryColor: AppColors.navyBlue,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navyBlue,
        secondary: AppColors.techBlue,
        surface: AppColors.cardLight,
        error: AppColors.statusCritical,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      textTheme: defaultTextTheme.copyWith(
        displayLarge: defaultTextTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontFamilyFallback: fontFallbacks,
        ),
        titleLarge: defaultTextTheme.titleLarge?.copyWith(
          color: AppColors.navyBlue,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          fontFamilyFallback: fontFallbacks,
        ),
        titleMedium: defaultTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamilyFallback: fontFallbacks,
        ),
        titleSmall: defaultTextTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamilyFallback: fontFallbacks,
        ),
        bodyLarge: defaultTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontFamilyFallback: fontFallbacks,
        ),
        bodyMedium: defaultTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontFamilyFallback: fontFallbacks,
        ),
        bodySmall: defaultTextTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontSize: 11,
          fontFamilyFallback: fontFallbacks,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
          fontFamilyFallback: fontFallbacks,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 1.5,
        shadowColor: AppColors.navyBlue.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.techBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontFamilyFallback: fontFallbacks,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.techBlue,
          side: const BorderSide(color: AppColors.techBlue, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontFamilyFallback: fontFallbacks,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    const defaultDarkTheme = Typography.whiteMountainView;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Plus Jakarta Sans',
      fontFamilyFallback: fontFallbacks,
      primaryColor: AppColors.navyBlue,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.techBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.darkCard,
        error: AppColors.statusCritical,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textLight,
        onError: AppColors.white,
      ),
      textTheme: defaultDarkTheme.copyWith(
        displayLarge: defaultDarkTheme.displayLarge?.copyWith(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
          fontFamilyFallback: fontFallbacks,
        ),
        titleLarge: defaultDarkTheme.titleLarge?.copyWith(
          color: AppColors.textLight,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          fontFamilyFallback: fontFallbacks,
        ),
        titleMedium: defaultDarkTheme.titleMedium?.copyWith(
          color: AppColors.textLight,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamilyFallback: fontFallbacks,
        ),
        titleSmall: defaultDarkTheme.titleSmall?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamilyFallback: fontFallbacks,
        ),
        bodyLarge: defaultDarkTheme.bodyLarge?.copyWith(
          color: AppColors.textLight,
          fontSize: 14,
          fontFamilyFallback: fontFallbacks,
        ),
        bodyMedium: defaultDarkTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
          fontSize: 13,
          fontFamilyFallback: fontFallbacks,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
          fontFamilyFallback: fontFallbacks,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
