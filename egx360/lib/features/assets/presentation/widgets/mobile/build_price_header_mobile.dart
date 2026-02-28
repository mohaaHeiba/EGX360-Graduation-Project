import 'package:egx/core/helper/market_status_helper.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/generated/l10n.dart';

/// Dedicated Mobile Price Header
/// Only contains Price, Change, and Market Status
/// AppBar elements (Back, Logo, Actions) are handled by SliverAppBar in the page
Widget buildPriceHeaderMobile(
  double currentPrice,
  double prevClose,
  String symbol,
  BuildContext context,
  AssetDetailsController controller, {
  bool isCrypto = false,
  bool isIndex = false,
  bool isEgp = true,
  double rate = 1.0,
}) {
  // Apply rate if isEgp is true, otherwise use 1.0 (USD)
  final displayPrice = currentPrice * (isEgp ? rate : 1.0);
  final displayPrevClose = prevClose * (isEgp ? rate : 1.0);

  final change = displayPrice - displayPrevClose;
  final changePercentage = displayPrevClose != 0
      ? (change / displayPrevClose) * 100
      : 0.0;
  final isPositive = change >= 0;

  String currencySymbol = S.of(context).asset_details_egp;
  if (isIndex) {
    currencySymbol = 'Pts';
  } else if (!isEgp) {
    currencySymbol = S.of(context).asset_details_usd;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Display
        PriceFormatter.buildRichPrice(
          context,
          price: displayPrice,
          currencySymbol: currencySymbol,
          priceStyle: context.textStyles.headlineLarge?.copyWith(
            color: context.onSurface,
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        // Change & Status Row
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
                color: MarketStatusHelper.getMarketStatusColor(
                  symbol: symbol,
                  isCrypto: isCrypto,
                ).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                MarketStatusHelper.getMarketStatusText(
                  context: context,
                  symbol: symbol,
                  isCrypto: isCrypto,
                ),
                style: TextStyle(
                  color: MarketStatusHelper.getMarketStatusColor(
                    symbol: symbol,
                    isCrypto: isCrypto,
                  ),
                  fontSize: 11,
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
