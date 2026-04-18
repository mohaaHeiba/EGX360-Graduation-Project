import 'package:egx/core/helper/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';
// Ensure this path matches your actual project structure
import 'package:egx/features/search/data/models/stock_model.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:get/get.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';

Widget buildListItem(BuildContext context, StockEntity stock) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  // IMPORTANT: check Currencies BEFORE Crypto — both have candle_table_name == 'API'
  final isCurrency = stock.sector == 'Currencies';
  final isCrypto = !isCurrency && stock.candleTableName == 'API';

  double currentPrice = stock.currentPrice ?? stock.prevClose ?? 0.0;
  if (isCurrency && Get.isRegistered<HomeController>()) {
    currentPrice = Get.find<HomeController>().currencyPrices[stock.symbol] ?? currentPrice;
  }

  return InkWell(
    onTap: () {
      String route;
      if (isCurrency) {
        route = AppPages.currencyDetailsPage;
      } else if (isCrypto) {
        route = AppPages.cryptoDetailsPage;
      } else {
        route = AppPages.stockDetailsPage;
      }

      Get.toNamed(
        route,
        arguments: {
          'id': stock.id,
          'stock_name': stock.symbol,
          'company_name': stock.companyNameEn ?? stock.companyNameAr,
          'logo_url': stock.logoUrl,
          'sector': stock.sector,
          'asset_type': isCurrency
              ? 'currency'
              : (isCrypto ? 'crypto' : 'stock'),
          'description': stock.description,
          'total_shares': stock.totalShares,
          'isin_code': stock.isinCode,
          'website': stock.website,
          'listing_date': stock.listingDate?.toIso8601String(),
          'candle_table_name': stock.candleTableName,
          'prev_close': stock.prevClose,
          'company_name_ar': stock.companyNameAr,
          'current_price': stock.currentPrice,
        },
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: stock.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: stock.logoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          stock.symbol.isNotEmpty ? stock.symbol[0] : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        stock.symbol.isNotEmpty ? stock.symbol[0] : '?',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        stock.symbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock.sector ?? context.s.search_egx_news,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stock.companyNameEn ?? stock.companyNameAr ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (currentPrice > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${PriceFormatter.formatPrice(currentPrice)} ${stock.sector == 'Indices'
                            ? context.s.search_pts
                            : (stock.sector == 'Crypto')
                            ? context.s.search_currency_usd
                            : context.s.search_egp}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: colorScheme.onSurface.withOpacity(0.4),
            size: 16,
          ),
        ],
      ),
    ),
  );
}
