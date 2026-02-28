import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceFormatter {
  /// Formats a price with thousands separators and conditional decimals.
  /// If price > 10,000, decimals are hidden.
  /// Otherwise, 2 decimal places are shown.
  static String formatPrice(double price) {
    if (price >= 10000) {
      return NumberFormat('#,###', 'en_US').format(price);
    } else {
      return NumberFormat('#,##0.00', 'en_US').format(price);
    }
  }

  /// Formats a large number into a compact format (e.g., 1.2M, 4.5B).
  static String formatCompactPrice(double price) {
    return NumberFormat.compact(locale: 'en_US').format(price);
  }

  /// Builds a RichText widget for displaying price with a styled currency symbol.
  static Widget buildRichPrice(
    BuildContext context, {
    required double price,
    required String currencySymbol,
    TextStyle? priceStyle,
    TextStyle? currencyStyle,
  }) {
    final formattedPrice = formatPrice(price);
    final theme = Theme.of(context);

    final effectivePriceStyle =
        priceStyle ??
        theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onSurface,
        );

    final effectiveCurrencyStyle =
        currencyStyle ??
        effectivePriceStyle?.copyWith(
          fontSize: (effectivePriceStyle.fontSize ?? 24) * 0.6,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: formattedPrice, style: effectivePriceStyle),
          const TextSpan(text: ' '), // Small space
          TextSpan(text: currencySymbol, style: effectiveCurrencyStyle),
        ],
      ),
    );
  }
}
