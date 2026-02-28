import 'package:flutter/material.dart';

class AppColors {
  // 🔵 Brand
  static const Color primary = Color.fromARGB(255, 40, 192, 177);
  static const Color primaryLight = Color(0xFF00F5FF);
  static const Color primaryDark = Color(0xFF00A9CC);

  // ⚫ Backgrounds (Dark Mode)
  static const Color background = Color(0xFF000000);
  static const Color surface = Color.fromARGB(
    255,
    33,
    33,
    33,
  ); // Cards / Panels
  static const Color overlay = Color(0xFF1A1D29); // Elevated surfaces

  // ⚪ Backgrounds (Light Mode)
  static const Color lightBackground = Color.fromARGB(255, 239, 239, 241);
  static const Color lightSurface = Color(0xFFF6F8FA);
  static const Color lightOverlay = Color(0xFFEDEFF2);

  // ⚪ Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B3C3);
  static const Color textFaint = Color(0xFF8A8D9B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF334155);
  static const Color textFaintLight = Color(0xFF94A3B8);

  // 💹 Trading
  static const Color candleGreen = Color(0xFF26A69A);
  static const Color candleRed = Color(0xFFEF5350);
  static const Color gridLine = Colors.white12;
  static const Color gridLineLight = Color(0xFFE2E8F0);

  // 🟢 Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFC107);

  // 🧊 Shadows & Glow
  static BoxShadow glow(Color color, {double opacity = 0.4}) => BoxShadow(
    color: color.withOpacity(opacity),
    blurRadius: 25,
    spreadRadius: 2,
    offset: const Offset(0, 0),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 8,
    offset: Offset(2, 2),
  );

  static const BoxShadow lightShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 12,
    offset: Offset(3, 3),
  );

  // 💠 Glassmorphism
  static Color get glassBackground => Colors.white.withOpacity(0.05);
  static Color get glassBackgroundLight => Colors.white.withOpacity(0.1);
  static Color get glassBorder => Colors.white.withOpacity(0.2);
  static Color get glassHighlight => primary.withOpacity(0.3);

  // 🎨 Gradient Colors
  static const List<Color> chartGradient = [
    Color(0xFF000000),
    Color(0xFF0A0E1A),
    Color(0xFF000000),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF00D9FF),
    Color(0xFF00A9CC),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF7B2CBF),
    Color(0xFF5A189A),
  ];

  // 🌟 Special Effects
  static Color get neonGlow => const Color(0xFF00FFD1).withOpacity(0.3);
  static Color get subtleOverlay => Colors.black.withOpacity(0.2);

  AppColors._();
}
