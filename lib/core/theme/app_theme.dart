// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

enum AppThemeMode { light, dark }

class AppTheme {
  static ThemeData themeFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.light:
      default:
        return lightTheme;
    }
  }
}
