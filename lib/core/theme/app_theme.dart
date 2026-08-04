import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';
import 'app_typography.dart';
import 'app_radius.dart';

// Globally disables all circular ink splash/ripple effects that cause
// Windows OpenGL shader compilation errors.
const _noSplash = NoSplash.splashFactory;
const _transparentOverlay = WidgetStatePropertyAll<Color>(Colors.transparent);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Inter',

      // ── Disable all ink splash (circular GPU shaders) ───────────────────
      splashFactory: _noSplash,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.primaryForegroundLight,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.secondaryForegroundLight,
        surface: AppColors.cardLight,
        onSurface: AppColors.foregroundLight,
        error: AppColors.destructiveLight,
        onError: AppColors.destructiveForegroundLight,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headline,
        titleLarge: AppTypography.title,
        titleMedium: AppTypography.subtitle,
        bodyLarge: AppTypography.body,
        labelLarge: AppTypography.button,
        bodyMedium: AppTypography.label,
        bodySmall: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
      ),
      // ── Zero-elevation card — shadow shaders cause OpenGL crash on Windows
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
      ),
      // ── Button themes — no splash, no shadow ────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
        ),
      ),
      dialogTheme: const DialogThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        splashColor: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        // Removes any default shadow or weird focus effects
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        // Sometimes scrollbars trigger shader compilation on fade out
      ),
      extensions: const [
        AppThemeExtension(
          success: AppColors.success,
          warning: AppColors.warning,
          danger: AppColors.destructiveLight,
          info: AppColors.info,
          disabled: AppColors.disabled,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Inter',

      // ── Disable all ink splash (circular GPU shaders) ───────────────────
      splashFactory: _noSplash,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.primaryForegroundDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.secondaryForegroundDark,
        surface: AppColors.cardDark,
        onSurface: AppColors.foregroundDark,
        error: AppColors.destructiveDark,
        onError: AppColors.destructiveForegroundDark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headline,
        titleLarge: AppTypography.title,
        titleMedium: AppTypography.subtitle,
        bodyLarge: AppTypography.body,
        labelLarge: AppTypography.button,
        bodyMedium: AppTypography.label,
        bodySmall: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.foregroundDark,
        elevation: 0,
      ),
      // ── Zero-elevation card — shadow shaders cause OpenGL crash on Windows
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
      ),
      // ── Button themes — no splash, no shadow ────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          splashFactory: _noSplash,
          overlayColor: _transparentOverlay,
        ),
      ),
      dialogTheme: const DialogThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        splashColor: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      extensions: const [
        AppThemeExtension(
          success: AppColors.success,
          warning: AppColors.warning,
          danger: AppColors.destructiveDark,
          info: AppColors.info,
          disabled: AppColors.disabled,
        ),
      ],
    );
  }
}
