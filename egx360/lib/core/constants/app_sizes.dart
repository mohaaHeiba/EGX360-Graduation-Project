import 'package:flutter/material.dart';

class AppSizes {
  // 🔹 Padding & Margin (مسافات)
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p48 = 48.0;

  // 🔹 Radius (نصف القطر للحواف)
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0;
  static const double r30 = 30.0;

  // 🔹 Icon Sizes (أحجام الأيقونات)
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // 🔹 Border Widths (سمك الحدود)
  static const double borderThin = 0.8;
  static const double borderMedium = 1.0;
  static const double borderThick = 1.2;

  // 🔹 Helpers (مساعدات سريعة)
  static const EdgeInsets paddingAll16 = EdgeInsets.all(p16);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: p16);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: p16);

  static BorderRadius radiusCircular16 = BorderRadius.circular(r16);
}
