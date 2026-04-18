import 'package:egx/core/helper/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';

class SearchStockCardDesktop extends StatefulWidget {
  final StockEntity stock;

  const SearchStockCardDesktop({super.key, required this.stock});

  @override
  State<SearchStockCardDesktop> createState() => _SearchStockCardDesktopState();
}

class _SearchStockCardDesktopState extends State<SearchStockCardDesktop> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // IMPORTANT: check Currencies BEFORE Crypto — both have candle_table_name == 'API'
    final isCurrency = widget.stock.sector == 'Currencies';
    final isCrypto = !isCurrency && widget.stock.candleTableName == 'API';

    // Calculate change (if available, otherwise 0)
    double currentPrice =
        widget.stock.currentPrice ?? widget.stock.prevClose ?? 0.0;
        
    if (isCurrency && Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      currentPrice = homeCtrl.currencyPrices[widget.stock.symbol] ?? currentPrice;
    }

    final prevClose = widget.stock.prevClose ?? 0.0;
    final change = prevClose != 0 ? currentPrice - prevClose : 0.0;
    final changePercent = prevClose != 0 ? (change / prevClose) * 100 : 0.0;
    final isPositive = change >= 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        String route;
        if (isCrypto) {
          route = AppPages.cryptoDetailsPage;
        } else if (isCurrency) {
          route = AppPages.currencyDetailsPage;
        } else {
          route = AppPages.stockDetailsPage;
        }

        Get.toNamed(
          route,
          arguments: {
            'id': widget.stock.id,
            'stock_name': widget.stock.symbol,
            'company_name':
                widget.stock.companyNameEn ?? widget.stock.companyNameAr,
            'logo_url': widget.stock.logoUrl,
            'sector': widget.stock.sector,
            'asset_type': isCrypto
                ? 'crypto'
                : (isCurrency ? 'currency' : 'stock'),
            'description': widget.stock.description,
            'total_shares': widget.stock.totalShares,
            'isin_code': widget.stock.isinCode,
            'website': widget.stock.website,
            'listing_date': widget.stock.listingDate?.toIso8601String(),
            'candle_table_name': widget.stock.candleTableName,
            'prev_close': widget.stock.prevClose,
            'company_name_ar': widget.stock.companyNameAr,
            'current_price': widget.stock.currentPrice,
          },
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                : colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: Logo & Name
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(2), // Optional spacing
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.stock.logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.stock.logoUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholder(colorScheme),
                            )
                          : _buildPlaceholder(theme.colorScheme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stock.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.stock.companyNameEn ??
                              widget.stock.companyNameAr ??
                              '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Middle: Price Large
              Text(
                PriceFormatter.formatPrice(currentPrice),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Bottom: Change & Sector
              Row(
                children: [
                  if (!isCurrency)
                    // Change Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isPositive ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: isPositive ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${changePercent.abs().toStringAsFixed(2)}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Sector Tag
                  Text(
                    widget.stock.sector ?? context.s.search_asset,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Text(
        widget.stock.symbol.isNotEmpty ? widget.stock.symbol[0] : '?',
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
