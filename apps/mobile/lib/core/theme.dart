import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// Terminal / geek-shell tokens — mirrors `apps/web` globals.css.
abstract final class SundayColors {
  static const background = Color(0xFF0B0908);
  static const foreground = Color(0xFFD4C4B4);
  static const ink = Color(0xFFF0E4D8);
  static const muted = Color(0xFF8A7464);
  static const accent = Color(0xFFD4926A);
  static const accentDeep = Color(0xFFB8734A);
  static const accentDim = Color(0x1FD4926A);
  static const accentInk = Color(0xFF140C08);
  static const navTrack = Color(0xFF14100E);
  static const panel = Color(0xFF100E0C);
  static const field = Color(0xFF0C0A08);
  static const shellTop = Color(0xFF0E0B09);
  static const line = Color(0x33D4926A);
  static const grid = Color(0x12D4926A);
  static const heroGlow = Color(0x1FD4926A);
}

ThemeData buildSundayTheme() {
  final display = GoogleFonts.spaceGroteskTextTheme();
  final mono = GoogleFonts.ibmPlexMonoTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SundayColors.background,
    colorScheme: const ColorScheme.dark(
      surface: SundayColors.background,
      primary: SundayColors.accent,
      onPrimary: SundayColors.accentInk,
      secondary: SundayColors.accentDeep,
      onSurface: SundayColors.foreground,
      outline: SundayColors.line,
    ),
    dividerColor: SundayColors.line,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SundayColors.panel,
      contentTextStyle: mono.bodyMedium?.copyWith(color: SundayColors.ink),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SundayColors.field,
      hintStyle: mono.bodyMedium?.copyWith(color: SundayColors.muted),
      labelStyle: mono.labelMedium?.copyWith(color: SundayColors.accent),
      errorStyle: mono.bodySmall?.copyWith(color: SundayColors.accentDeep),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SundayColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SundayColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SundayColors.accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SundayColors.accentDeep),
      ),
    ),
  );

  return base.copyWith(
    textTheme: mono
        .apply(
          bodyColor: SundayColors.foreground,
          displayColor: SundayColors.ink,
        )
        .copyWith(
          displayLarge: display.displayLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w600,
          ),
          displayMedium: display.displayMedium?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: display.headlineLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: display.headlineMedium?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: display.headlineSmall?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: display.titleLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
  );
}
