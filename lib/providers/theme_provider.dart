// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

const _kThemePrefKey = 'app_theme_mode_v1';

/// AsyncNotifier that loads/saves theme mode from SharedPreferences.
/// Use: ref.read(themeModeProvider.notifier).toggleTheme();
class ThemeNotifier extends AsyncNotifier<AppThemeMode> {
  @override
  Future<AppThemeMode> build() async {
    // Called once when the notifier is first created.
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kThemePrefKey);
      if (raw != null) {
        return AppThemeMode.values.firstWhere(
              (e) => e.toString() == raw,
          orElse: () => AppThemeMode.light,
        );
      }
    } catch (_) {
      // ignore and fall through to default
    }
    return AppThemeMode.light;
  }

  Future<void> _saveToPrefs(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemePrefKey, mode.toString());
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    // update state immediately for fast UI response
    state = AsyncData(mode);
    await _saveToPrefs(mode);
  }

  Future<void> toggleTheme() async {
    final current = state.value ?? AppThemeMode.light;
    final next = current == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setTheme(next);
  }
}

/// Provider exposing the current theme mode asynchronously.
final themeModeProvider =
AsyncNotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

/// Convenience provider that returns ThemeData synchronously (falls back to light).
final themeDataProvider = Provider<ThemeData>((ref) {
  final asyncMode = ref.watch(themeModeProvider);
  final mode = asyncMode.value ?? AppThemeMode.light;
  return AppTheme.themeFor(mode);
});
