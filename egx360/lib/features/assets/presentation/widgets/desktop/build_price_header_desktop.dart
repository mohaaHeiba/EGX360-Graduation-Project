import 'package:egx/core/helper/market_status_helper.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/generated/l10n.dart';
import 'package:get/get.dart';

/// Dedicated Desktop Price Header
Widget buildPriceHeaderDesktop(
  double currentPrice,
  double prevClose,
  String symbol,
  BuildContext context,
  AssetDetailsController controller,
  Map<String, dynamic> stockData, {
  bool isCrypto = false,
  bool isIndex = false,
  bool isEgp = true,
  double rate = 1.0,
}) {
  final stockName = stockData['symbol'] ?? symbol;
  final companyName = stockData['company_name'] ?? '';

  // Apply rate if isEgp is true, otherwise use 1.0 (USD)
  final displayPrice = currentPrice * (isEgp ? rate : 1.0);
  final displayPrevClose = prevClose * (isEgp ? rate : 1.0);

  final change = displayPrice - displayPrevClose;
  final changePercentage = displayPrevClose != 0
      ? (change / displayPrevClose) * 100
      : 0.0;
  final isPositive = change >= 0;

  String currencySymbol = 'EGP';
  if (isIndex) {
    currencySymbol = 'Pts';
  } else if (!isEgp) {
    currencySymbol = '\$';
  }

  final isMaterial =
      controller.symbol == 'GOLD' || controller.symbol == 'SILVER';

  return Row(
    children: [
      // Large Logo
      CircleAvatar(
        radius: 40,
        backgroundImage: stockData['logo_url'] != null
            ? NetworkImage(stockData['logo_url']!)
            : null,
        backgroundColor: Colors.grey[800],
        child: stockData['logo_url'] == null
            ? Text(
                stockName.isNotEmpty ? stockName[0] : '?',
                style: context.textStyles.headlineLarge?.copyWith(
                  color: context.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      const SizedBox(width: 20),

      // Stock Info Column (Left)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            Text(
              companyName.isNotEmpty ? companyName : stockName,
              style: context.textStyles.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Symbol + Exchange + Market Status
            Row(
              children: [
                Text(
                  symbol,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: context.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "•",
                  style: TextStyle(color: context.onSurface.withOpacity(0.3)),
                ),
                const SizedBox(width: 8),
                Text(
                  isIndex
                      ? S.of(context).market_egx
                      : isCrypto
                      ? S.of(context).market_crypto
                      : S.of(context).market_egx,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: context.onSurface.withOpacity(0.7),
                  ),
                ),
                if (!isCrypto) ...[
                  const SizedBox(width: 12),
                  // Market Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          MarketStatusHelper.isMarketOpen(
                            symbol: symbol,
                            isCrypto: isCrypto,
                          )
                          ? Colors.green.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            MarketStatusHelper.isMarketOpen(
                              symbol: symbol,
                              isCrypto: isCrypto,
                            )
                            ? Colors.green
                            : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                MarketStatusHelper.isMarketOpen(
                                  symbol: symbol,
                                  isCrypto: isCrypto,
                                )
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          MarketStatusHelper.isMarketOpen(
                                symbol: symbol,
                                isCrypto: isCrypto,
                              )
                              ? S.of(context).market_status_open
                              : S.of(context).market_status_closed,
                          style: context.textStyles.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                MarketStatusHelper.isMarketOpen(
                                  symbol: symbol,
                                  isCrypto: isCrypto,
                                )
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Price Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // Large Price
                Text(
                  PriceFormatter.formatPrice(displayPrice),
                  style: context.textStyles.headlineLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: context.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                // Currency superscript
                Text(
                  currencySymbol,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontSize: 16,
                    color: context.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),

                // Change and Percentage
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${isPositive ? '+' : ''}${PriceFormatter.formatPrice(change)}",
                        style: context.textStyles.titleMedium?.copyWith(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(2)}%",
                        style: context.textStyles.titleMedium?.copyWith(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Right Side Actions
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMaterial)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.onSurface.withOpacity(0.1)),
              ),
              child: InkWell(
                onTap: () => controller.toggleCurrency(),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: 16,
                      color: context.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.isEgp.value
                          ? S.of(context).asset_details_egp
                          : S.of(context).asset_details_usd,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Watchlist Button
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.onSurface.withOpacity(0.1)),
            ),
            child: Obx(
              () => IconButton(
                icon: Icon(
                  controller.isWatchlisted.value
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: controller.isWatchlisted.value
                      ? context.primary
                      : context.onSurface,
                ),
                onPressed: () => controller.toggleWatchlist(),
                tooltip: controller.isWatchlisted.value
                    ? S.of(context).watchlist_remove
                    : S.of(context).watchlist_add,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
