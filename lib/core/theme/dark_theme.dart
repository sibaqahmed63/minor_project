// lib/core/theme/dark_theme.dart

import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,

  // ---------------------------------------------------------------------------
  // GLOBAL
  // ---------------------------------------------------------------------------
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.surfaceDark,

  primaryColor: AppColors.primaryGradientEnd,

  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryGradientEnd,
    secondary: AppColors.accentGold,

    surface: AppColors.surfaceMutedDark,

    onPrimary: Colors.white,
    onSecondary: Colors.black,

    onSurface: AppColors.textPrimaryDark,
  ),

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  textTheme: AppTypography.textTheme.apply(
    bodyColor: AppColors.textPrimaryDark,
    displayColor: AppColors.textPrimaryDark,
  ),

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,

    iconTheme: const IconThemeData(
      color: AppColors.accentGold,
      size: 22,
    ),

    titleTextStyle: AppTypography.displaySmall.copyWith(
      color: AppColors.accentGold,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  ),

  // ---------------------------------------------------------------------------
  // CARDS
  // ---------------------------------------------------------------------------
  cardTheme: CardThemeData(
    color: const Color(0xFF0F1724),

    elevation: 10,

    shadowColor: Colors.black.withOpacity(0.45),

    margin: EdgeInsets.zero,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: Colors.white.withOpacity(0.035),
        width: 1,
      ),
    ),
  ),

  // ---------------------------------------------------------------------------
  // ELEVATED BUTTON
  // ---------------------------------------------------------------------------
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentGold,
      foregroundColor: Colors.black,

      elevation: 6,

      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 20,
      ),

      minimumSize: const Size(0, 48),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      textStyle: AppTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
  ),

  // ---------------------------------------------------------------------------
  // OUTLINED BUTTON
  // ---------------------------------------------------------------------------
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.accentGold,

      side: BorderSide(
        color: AppColors.accentGold.withOpacity(0.55),
        width: 1,
      ),

      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 18,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  // ---------------------------------------------------------------------------
  // TEXT BUTTON
  // ---------------------------------------------------------------------------
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accentGold,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),

  // ---------------------------------------------------------------------------
  // INPUT FIELDS
  // ---------------------------------------------------------------------------
  inputDecorationTheme: InputDecorationTheme(
    filled: true,

    fillColor: Colors.white.withOpacity(0.035),

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.08),
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.08),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.accentGold,
        width: 1.4,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.redAccent,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.redAccent,
        width: 1.4,
      ),
    ),

    labelStyle: TextStyle(
      color: AppColors.textSecondaryDark,
    ),

    hintStyle: TextStyle(
      color: AppColors.textSecondaryDark.withOpacity(0.7),
    ),

    prefixIconColor: AppColors.textSecondaryDark,
    suffixIconColor: AppColors.textSecondaryDark,
  ),

  // ---------------------------------------------------------------------------
  // FLOATING ACTION BUTTON
  // ---------------------------------------------------------------------------
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentGold,
    foregroundColor: Colors.black,

    elevation: 8,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // ---------------------------------------------------------------------------
  // DIVIDERS
  // ---------------------------------------------------------------------------
  dividerColor: AppColors.borderDark,

  // ---------------------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ---------------------------------------------------------------------------
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceMutedDark,

    selectedItemColor: AppColors.accentGold,

    unselectedItemColor: AppColors.textSecondaryDark,

    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),

    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
    ),

    elevation: 14,

    type: BottomNavigationBarType.fixed,

    showUnselectedLabels: true,
  ),

  // ---------------------------------------------------------------------------
  // DIALOGS
  // ---------------------------------------------------------------------------
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceMutedDark,

    elevation: 20,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),

    titleTextStyle: AppTypography.displaySmall.copyWith(
      color: AppColors.textPrimaryDark,
      fontWeight: FontWeight.w700,
    ),

    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
  ),

  // ---------------------------------------------------------------------------
  // SNACKBAR
  // ---------------------------------------------------------------------------
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF182235),

    contentTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontWeight: FontWeight.w500,
    ),

    actionTextColor: AppColors.accentGold,

    behavior: SnackBarBehavior.floating,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  // ---------------------------------------------------------------------------
  // SWITCH
  // ---------------------------------------------------------------------------
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentGold;
        }
        return Colors.grey.shade500;
      },
    ),
    trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentGold.withOpacity(0.35);
        }
        return Colors.white.withOpacity(0.10);
      },
    ),
  ),

  // ---------------------------------------------------------------------------
  // CHECKBOX
  // ---------------------------------------------------------------------------
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(
      color: AppColors.textSecondaryDark,
    ),

    fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentGold;
        }
        return Colors.transparent;
      },
    ),

    checkColor: WidgetStateProperty.all(
      Colors.black,
    ),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),

  // ---------------------------------------------------------------------------
  // CHIPS
  // ---------------------------------------------------------------------------
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.05),

    selectedColor: AppColors.accentGold.withOpacity(0.18),

    side: BorderSide(
      color: Colors.white.withOpacity(0.07),
    ),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),

    labelStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontWeight: FontWeight.w500,
    ),
  ),

  // ---------------------------------------------------------------------------
  // PROGRESS INDICATORS
  // ---------------------------------------------------------------------------
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accentGold,
  ),

  // ---------------------------------------------------------------------------
  // VISUAL DENSITY
  // ---------------------------------------------------------------------------
  visualDensity: VisualDensity.adaptivePlatformDensity,

  // ---------------------------------------------------------------------------
  // PAGE TRANSITIONS
  // ---------------------------------------------------------------------------
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android:
      FadeUpwardsPageTransitionsBuilder(),

      TargetPlatform.iOS:
      CupertinoPageTransitionsBuilder(),
    },
  ),
);