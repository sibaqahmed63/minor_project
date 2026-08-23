// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient endpoints (use for app bars, hero cards)
  static const Color primaryGradientStart = Color(0xFF0F172A); // deep indigo
  static const Color primaryGradientEnd = Color(0xFF2B3A67);   // indigo blue

  // Accent
  static const Color accentGold = Color(0xFFFFC857);
  static const Color accentAmber = Color(0xFFFFB020);

  // Surfaces
  static const Color surfaceLight = Color(0xFFFBFBFD);
  static const Color surfaceMutedLight = Color(0xFFF4F6F9);
  static const Color surfaceDark = Color(0xFF0B0F1A);
  static const Color surfaceMutedDark = Color(0xFF0F1724);

  // Text
  static const Color textPrimaryLight = Color(0xFF0B1B2B);
  static const Color textSecondaryLight = Color(0xFF5B6B7A);
  static const Color textPrimaryDark = Color(0xFFEFF6FF);
  static const Color textSecondaryDark = Color(0xFF9AA4B2);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4DA6FF);

  // Node status colors
  static const Color nodeHealthy = Color(0xFF2ECC71);
  static const Color nodeWarning = Color(0xFFFFB020);
  static const Color nodeOffline = Color(0xFFB0BEC5);

  // Neutral tokens
  static const Color borderLight = Color(0xFFE6E9EE);
  static const Color borderDark = Color(0xFF1F2A37);

  // Glass / translucent overlays
  static Color glassLight(double opacity) => Colors.white.withOpacity(opacity);
  static Color glassDark(double opacity) => Colors.black.withOpacity(opacity * 0.45);

  // Utility gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE6B3), accentGold],
  );
}
