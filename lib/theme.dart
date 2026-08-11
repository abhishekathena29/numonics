import 'package:flutter/material.dart';

/// Central design tokens for Numonics.
///
/// Visual language: a clean, near-white canvas with soft mint-tinted surfaces,
/// a single confident teal-green brand color, generous rounding and airy
/// spacing. Minimal, modern and friendly — built to feel like a calm,
/// contemporary learning app.
class AppColors {
  AppColors._();

  // Brand — a calm teal-green
  static const Color primary = Color(0xFF2E7A68);
  static const Color primaryDark = Color(0xFF245F52);
  static const Color primaryTint = Color(0xFFE4F0EC); // soft filled surfaces
  static const Color primaryTintStrong = Color(0xFFCFE6DE);
  static const Color mint = Color(0xFF3AA88F);

  // Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgSoft = Color(0xFFF5F8F7);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fill = Color(0xFFF1F5F3); // inputs, inset chips

  // Accents
  static const Color amber = Color(0xFFE39A0B);
  static const Color amberTint = Color(0xFFFBEBCF);
  static const Color coral = Color(0xFFE5634D); // wrong answers / errors
  static const Color coralTint = Color(0xFFFBE3DE);
  static const Color sky = Color(0xFF2BA6E8);

  // Neutrals (ink)
  static const Color ink = Color(0xFF17211E);
  static const Color inkSoft = Color(0xFF69756F);
  static const Color inkFaint = Color(0xFFA4ADA9);

  // Lines
  static Color stroke = const Color(0xFF17211E).withValues(alpha: 0.06);
  static Color divider = const Color(0xFF17211E).withValues(alpha: 0.07);

  // Legacy aliases (kept so any stray call-site keeps compiling)
  static const Color violet = primary;
  static Color get glass => surface;
  static Color get glassStrong => fill;
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34917C), AppColors.primary],
  );

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryTint, AppColors.primaryTintStrong],
  );
}

ThemeData buildNumonicsTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.mint,
    surface: AppColors.surface,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
      fontFamily: 'Roboto',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.ink,
      centerTitle: false,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}

/// Convenience text styles.
class AppText {
  AppText._();
  static const TextStyle display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.6,
    height: 1.1,
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.4,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.2,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.inkSoft,
    height: 1.45,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
    letterSpacing: 0.2,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Courier', 'Menlo', 'monospace'],
    fontSize: 14,
    color: AppColors.ink,
  );
}
