import 'package:egx/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/theme/app_gredients.dart';

class LightTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,

    // Extensions
    extensions: [AppGradients.light],

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
    ),

    cardColor: AppColors.lightSurface,
    dialogBackgroundColor: AppColors.lightOverlay,

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderLarge,
        ), // ثابت
        shadowColor: AppColors.primary.withOpacity(0.2),
        elevation: 5,
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
      fillColor: AppColors.lightOverlay,
      hintStyle: const TextStyle(color: AppColors.textFaintLight),
      contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
      border: OutlineInputBorder(
        borderRadius: AppDimensions.borderMedium, // ثابت
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppDimensions.borderWidthMedium,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderMedium,
        borderSide: const BorderSide(
          color: AppColors.primaryDark,
          width: AppDimensions.borderWidthThick,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderMedium,
        borderSide: const BorderSide(
          color: AppColors.textFaintLight,
          width: AppDimensions.borderWidthThin,
        ),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimaryLight,
        letterSpacing: 2.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
      labelSmall: TextStyle(fontSize: 12, color: AppColors.textFaintLight),
    ),
  );
}
