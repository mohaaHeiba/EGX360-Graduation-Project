import 'package:egx/core/theme/app_gredients.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  // Localization
  S get s => S.of(this);

  // MediaQuery
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;

  // Theme
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colors => appTheme.colorScheme;
  TextTheme get textStyles => appTheme.textTheme;

  bool get isDark => appTheme.brightness == Brightness.dark;

  // Common Colors
  Color get primary => colors.primary;
  Color get onPrimary => colors.onPrimary;
  Color get background => colors.background;
  Color get surface => colors.surface;
  Color get onBackground => colors.onBackground;
  Color get onSurface => colors.onSurface;

  // Gradients
  AppGradients get gradients => Theme.of(this).extension<AppGradients>()!;

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}
