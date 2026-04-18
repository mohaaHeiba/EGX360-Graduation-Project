import 'package:flutter/material.dart';

class AppDimensions {
  // الحواف (Borders & Radius)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 16.0;
  static BorderRadius borderSmall = BorderRadius.circular(radiusSmall);
  static BorderRadius borderMedium = BorderRadius.circular(radiusMedium);
  static BorderRadius borderLarge = BorderRadius.circular(radiusLarge);

  // سمك الحدود (Width)
  static const double borderWidthThin = 0.8;
  static const double borderWidthMedium = 1.0;
  static const double borderWidthThick = 1.2;

  // المسافات (Padding & Margin)
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}
