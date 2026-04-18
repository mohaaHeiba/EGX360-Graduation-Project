import 'package:egx/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:egx/core/helper/context_extensions.dart';

Widget buildCurrencyPriceHeader(
  double currentPrice,
  double prevClose,
  BuildContext context,
) {
  final change = currentPrice - prevClose;
  final changePercentage = prevClose != 0 ? (change / prevClose) * 100 : 0.0;
  final isPositive = change >= 0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PriceFormatter.buildRichPrice(
          context,
          price: currentPrice,
          currencySymbol: 'EGP',
          priceStyle: context.textStyles.headlineLarge?.copyWith(
            color: context.onSurface,
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
        ),
        Row(
          children: [
            Icon(
              isPositive
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              size: 32,
            ),
            Text(
              "${change > 0 ? '+' : ''}${PriceFormatter.formatPrice(change)} (${changePercentage.toStringAsFixed(2)}%)",
              style: context.textStyles.bodyMedium?.copyWith(
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withOpacity(
                  0.2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPositive ? "Open" : "Closed",
                style: context.textStyles.bodyMedium?.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
