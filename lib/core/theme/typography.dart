// lib/core/theme/typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  // Font families (add these fonts to pubspec.yaml and assets or use Google Fonts package)
  static const String displayFont = 'PlayfairDisplay';
  static const String uiFont = 'Inter';

  // Headline / display styles (premium serif for headings)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    height: 1.18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  // UI / body styles (clean sans for readability)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: uiFont,
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: uiFont,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: uiFont,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: uiFont,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelSmall: label,
  );
}
