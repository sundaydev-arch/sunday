import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// App-only — Clear Day.
/// Cool light editorial: soft sky wash, sharp ink, one accent.
abstract final class SundayColors {
  static const background = Color(0xFFF0F4F8);
  static const backgroundLift = Color(0xFFF7FAFC);
  static const foreground = Color(0xFF3D4F5F);
  static const ink = Color(0xFF0B1C2C);
  static const muted = Color(0xFF5B6B7C);
  static const accent = Color(0xFF0B7EA4);
  static const accentDeep = Color(0xFF08627F);
  static const accentDim = Color(0x1A0B7EA4);
  static const accentInk = Color(0xFFFFFFFF);
  static const navTrack = Color(0xF2FFFFFF);
  static const panel = Color(0xFFFFFFFF);
  static const field = Color(0xFFFFFFFF);
  static const shellTop = Color(0xFFF0F4F8);
  static const line = Color(0xFFD5DEE7);
  static const lineStrong = Color(0xFFB8C5D1);
  static const grid = Color(0x0A0B1C2C);
  static const heroGlow = Color(0x660B7EA4);
  static const glowCool = Color(0x330B7EA4);
  static const danger = Color(0xFFE11D48);
}

abstract final class SundayRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

abstract final class SundaySpace {
  static const pageX = 28.0;
  static const section = 48.0;
}

ThemeData buildSundayTheme() {
  final display = GoogleFonts.outfitTextTheme();
  final body = GoogleFonts.dmSansTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: SundayColors.background,
    colorScheme: const ColorScheme.light(
      surface: SundayColors.background,
      primary: SundayColors.accent,
      onPrimary: SundayColors.accentInk,
      secondary: SundayColors.accentDeep,
      onSurface: SundayColors.foreground,
      outline: SundayColors.line,
      error: SundayColors.danger,
    ),
    dividerColor: SundayColors.line,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SundayColors.ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: SundayColors.ink.withValues(alpha: 0.35),
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SundayRadii.pill),
        ),
        textStyle: body.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SundayColors.ink,
        side: const BorderSide(color: SundayColors.lineStrong, width: 1.25),
        backgroundColor: Colors.white.withValues(alpha: 0.55),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SundayRadii.pill),
        ),
        textStyle: body.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SundayColors.accentDeep,
        textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SundayColors.ink,
      contentTextStyle: body.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SundayRadii.md),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: SundayColors.accentDim,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 60,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return body.labelSmall?.copyWith(
          color: active ? SundayColors.ink : SundayColors.muted,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          fontSize: 11,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return IconThemeData(
          color: active ? SundayColors.ink : SundayColors.muted,
          size: 22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SundayColors.field,
      hintStyle: body.bodyMedium?.copyWith(color: SundayColors.muted),
      errorStyle: body.bodySmall?.copyWith(color: SundayColors.danger),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SundayRadii.sm),
        borderSide: const BorderSide(color: SundayColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SundayRadii.sm),
        borderSide: const BorderSide(color: SundayColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SundayRadii.sm),
        borderSide: const BorderSide(color: SundayColors.ink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SundayRadii.sm),
        borderSide: const BorderSide(color: SundayColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SundayRadii.sm),
        borderSide: const BorderSide(color: SundayColors.danger, width: 1.5),
      ),
    ),
  );

  return base.copyWith(
    textTheme: body
        .apply(
          bodyColor: SundayColors.foreground,
          displayColor: SundayColors.ink,
        )
        .copyWith(
          displayMedium: display.displayMedium?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.8,
            height: 0.98,
          ),
          headlineLarge: display.headlineLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            height: 1.05,
          ),
          headlineSmall: display.headlineSmall?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.15,
          ),
          titleLarge: display.titleLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.35,
            height: 1.2,
          ),
          titleMedium: body.titleMedium?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
          titleSmall: body.titleSmall?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: body.bodyLarge?.copyWith(
            color: SundayColors.foreground,
            height: 1.55,
            fontSize: 16.5,
          ),
          bodyMedium: body.bodyMedium?.copyWith(
            color: SundayColors.foreground,
            height: 1.5,
          ),
          bodySmall: body.bodySmall?.copyWith(
            color: SundayColors.muted,
            height: 1.4,
          ),
          labelLarge: body.labelLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
          ),
          labelMedium: body.labelMedium?.copyWith(
            color: SundayColors.accentDeep,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: body.labelSmall?.copyWith(
            color: SundayColors.muted,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
  );
}
