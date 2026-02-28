import 'package:egx/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/theme/app_gredients.dart';

class DarkTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    // Extensions
    extensions: const [AppGradients.dark],

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),

    cardColor: AppColors.surface,
    dialogBackgroundColor: AppColors.overlay,

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderLarge,
        ), // استخدمنا الثابت
        shadowColor: AppColors.primary.withOpacity(0.25),
        elevation: 8,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),

    // Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.overlay,
      hintStyle: const TextStyle(color: AppColors.textFaint),
      contentPadding: const EdgeInsets.all(
        AppDimensions.paddingMedium,
      ), // مسافات موحدة
      border: OutlineInputBorder(
        borderRadius: AppDimensions.borderMedium, // استخدمنا الثابت
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppDimensions.borderWidthMedium,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderMedium,
        borderSide: const BorderSide(
          color: AppColors.primaryLight,
          width: AppDimensions.borderWidthThick,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderMedium,
        borderSide: const BorderSide(
          color: AppColors.textFaint,
          width: AppDimensions.borderWidthThin,
        ),
      ),
    ),

    // Text Theme (ممكن تنقله برضه بس كدا تمام)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: 2.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      labelSmall: TextStyle(fontSize: 12, color: AppColors.textFaint),
    ),
  );
}
