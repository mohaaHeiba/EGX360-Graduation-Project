import 'package:flutter/material.dart';

class AppGradients extends ThemeExtension<AppGradients> {
  final LinearGradient logo;
  final LinearGradient background;
  final LinearGradient overlay;

  const AppGradients({
    required this.logo,
    required this.background,
    required this.overlay,
  });

  // 🌑 Dark Theme Gradients (أسود بالكامل)
  static const AppGradients dark = AppGradients(
    logo: LinearGradient(
      colors: [
        Color.fromARGB(255, 40, 192, 177),
        Color.fromARGB(255, 40, 192, 177),
        Colors.white,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black, Colors.black, Colors.black],
    ),
    overlay: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black, Colors.black, Colors.black],
      stops: [0.0, 0.6, 1.0],
    ),
  );

  // ☀️ Light Theme Gradients
  static AppGradients light = AppGradients(
    logo: const LinearGradient(
      colors: [
        Color.fromARGB(255, 40, 192, 177),
        Color.fromARGB(255, 60, 220, 205),
        Color(0xFF00F5FF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey.shade400,
        Colors.grey.shade300,
        Colors.grey.shade200,
      ],
    ),
    overlay: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.9),
        Colors.grey.shade100.withOpacity(0.95),
        Colors.grey.shade200.withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    ),
  );

  @override
  AppGradients copyWith({
    LinearGradient? logo,
    LinearGradient? background,
    LinearGradient? overlay,
  }) {
    return AppGradients(
      logo: logo ?? this.logo,
      background: background ?? this.background,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(
      logo: LinearGradient.lerp(logo, other.logo, t)!,
      background: LinearGradient.lerp(background, other.background, t)!,
      overlay: LinearGradient.lerp(overlay, other.overlay, t)!,
    );
  }
}
