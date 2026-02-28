import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget to display a single stock search result item
class StockSearchItemWidget extends StatelessWidget {
  final StockEntity stock;
  final VoidCallback onTap;

  const StockSearchItemWidget({
    super.key,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCrypto = stock.candleTableName == 'API';
    final isCurrency = stock.sector == 'Currency';
    final currencySymbol = isCrypto ? '\$' : (isCurrency ? '' : 'EGP');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Logo/Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
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
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Stock Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symbol and Sector Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stock.symbol,
                          style: context.textStyles.titleMedium?.copyWith(
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
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stock.sector ?? 'EGX',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Company Name and Price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stock.companyNameEn ?? stock.companyNameAr ?? '',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((stock.currentPrice ?? stock.prevClose ?? 0) > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${PriceFormatter.formatPrice(stock.currentPrice ?? stock.prevClose ?? 0)} $currencySymbol',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
