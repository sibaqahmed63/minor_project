// lib/core/theme/light_theme.dart

import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,

  // ---------------------------------------------------------------------------
  // GLOBAL
  // ---------------------------------------------------------------------------
  useMaterial3: true,

  // Soft premium background instead of pure white
  scaffoldBackgroundColor: const Color(0xFFF5F7FA),

  primaryColor: AppColors.primaryGradientStart,

  colorScheme: ColorScheme.light(
    primary: AppColors.primaryGradientStart,
    secondary: AppColors.accentGold,

    // Main app background
    surface: const Color(0xFFFFFFFF),

    onPrimary: Colors.white,
    onSecondary: Colors.black,

    onSurface: AppColors.textPrimaryLight,
  ),

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  textTheme: AppTypography.textTheme.apply(
    bodyColor: AppColors.textPrimaryLight,
    displayColor: AppColors.textPrimaryLight,
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
      color: AppColors.primaryGradientEnd,
      size: 22,
    ),

    titleTextStyle: AppTypography.displaySmall.copyWith(
      color: AppColors.primaryGradientEnd,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  ),

  // ---------------------------------------------------------------------------
  // CARDS
  // ---------------------------------------------------------------------------
  cardTheme: CardThemeData(
    // Slightly warm white so cards don't disappear into the background
    color: const Color(0xFFFFFFFF),

    elevation: 4,

    shadowColor: const Color(0x1A0F172A),

    margin: EdgeInsets.zero,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),

      // Very subtle border gives the card definition
      side: const BorderSide(
        color: Color(0xFFE8ECF2),
        width: 1,
      ),
    ),
  ),

  // ---------------------------------------------------------------------------
  // ELEVATED BUTTON
  // ---------------------------------------------------------------------------
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGradientEnd,

      foregroundColor: Colors.white,

      elevation: 4,

      shadowColor: AppColors.primaryGradientEnd.withOpacity(0.25),

      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 20,
      ),

      minimumSize: const Size(0, 48),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      textStyle: AppTypography.bodyMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  // ---------------------------------------------------------------------------
  // OUTLINED BUTTON
  // ---------------------------------------------------------------------------
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryGradientEnd,

      side: BorderSide(
        color: AppColors.primaryGradientEnd.withOpacity(0.35),
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
      foregroundColor: AppColors.primaryGradientEnd,

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

    fillColor: const Color(0xFFF8FAFC),

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),

      borderSide: const BorderSide(
        color: Color(0xFFE1E6ED),
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),

      borderSide: const BorderSide(
        color: Color(0xFFE1E6ED),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),

      borderSide: BorderSide(
        color: AppColors.primaryGradientEnd,
        width: 1.5,
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
        width: 1.5,
      ),
    ),

    labelStyle: TextStyle(
      color: AppColors.textSecondaryLight,
    ),

    hintStyle: TextStyle(
      color: AppColors.textSecondaryLight.withOpacity(0.75),
    ),

    prefixIconColor: AppColors.textSecondaryLight,

    suffixIconColor: AppColors.textSecondaryLight,
  ),

  // ---------------------------------------------------------------------------
  // FLOATING ACTION BUTTON
  // ---------------------------------------------------------------------------
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentGold,

    foregroundColor: Colors.black,

    elevation: 6,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // ---------------------------------------------------------------------------
  // DIVIDERS
  // ---------------------------------------------------------------------------
  dividerColor: AppColors.borderLight,

  // ---------------------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ---------------------------------------------------------------------------
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,

    selectedItemColor: AppColors.primaryGradientEnd,

    unselectedItemColor: AppColors.textSecondaryLight,

    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),

    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
    ),

    elevation: 12,

    type: BottomNavigationBarType.fixed,

    showUnselectedLabels: true,
  ),

  // ---------------------------------------------------------------------------
  // DIALOG
  // ---------------------------------------------------------------------------
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,

    elevation: 18,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),

    titleTextStyle: AppTypography.displaySmall.copyWith(
      color: AppColors.textPrimaryLight,
      fontWeight: FontWeight.w700,
    ),

    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryLight,
    ),
  ),

  // ---------------------------------------------------------------------------
  // SNACKBAR
  // ---------------------------------------------------------------------------
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF172033),

    contentTextStyle: const TextStyle(
      color: Colors.white,
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
          return AppColors.primaryGradientEnd;
        }

        return Colors.grey.shade500;
      },
    ),

    trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGradientEnd.withOpacity(0.25);
        }

        return const Color(0xFFE1E6ED);
      },
    ),
  ),

  // ---------------------------------------------------------------------------
  // CHECKBOX
  // ---------------------------------------------------------------------------
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(
      color: AppColors.textSecondaryLight,
    ),

    fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGradientEnd;
        }

        return Colors.transparent;
      },
    ),

    checkColor: WidgetStateProperty.all(
      Colors.white,
    ),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),

  // ---------------------------------------------------------------------------
  // CHIPS
  // ---------------------------------------------------------------------------
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF1F4F8),

    selectedColor: AppColors.primaryGradientEnd.withOpacity(0.12),

    side: const BorderSide(
      color: Color(0xFFE1E6ED),
    ),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),

    labelStyle: TextStyle(
      color: AppColors.textPrimaryLight,
      fontWeight: FontWeight.w500,
    ),
  ),

  // ---------------------------------------------------------------------------
  // PROGRESS INDICATORS
  // ---------------------------------------------------------------------------
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.primaryGradientEnd,

    linearTrackColor: const Color(0xFFE5EAF0),
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