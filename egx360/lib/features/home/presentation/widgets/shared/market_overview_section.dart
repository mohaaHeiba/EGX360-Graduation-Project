import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MarketOverviewSection extends StatelessWidget {
  final List<StockModel> indices;
  final List<StockModel> trendingStocks;

  const MarketOverviewSection({
    super.key,
    required this.indices,
    required this.trendingStocks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),

          // Indices in a ROW
          if (indices.isNotEmpty)
            Row(
              children: indices.take(2).map((idx) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: idx == indices.first ? 10 : 0,
                      left: idx != indices.first ? 0 : 0,
                    ),
                    child: _buildIndexCard(context, idx),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primary.withOpacity(0.2),
                context.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.analytics_rounded,
            color: context.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.s.market_indices_title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIndexCard(BuildContext context, StockModel index) {
    final changePercent = index.changePercent ?? 0.0;
    final isPositive = changePercent >= 0;
    final changeColor = isPositive
        ? AppColors.candleGreen
        : AppColors.candleRed;

    return GestureDetector(
      onTap: () => Get.find<HomeController>().openStockDetails(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.surface.withOpacity(0.5),
              context.surface.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.onSurface.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo image instead of icon
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: index.logoUrl?.isNotEmpty == true
                        ? Image.network(
                            index.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFallbackLogo(context, index.symbol),
                          )
                        : _buildFallbackLogo(context, index.symbol),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  index.symbol,
                  style: TextStyle(
                    color: context.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price
            Text(
              NumberFormat('#,##0.00').format(index.currentPrice ?? 0),
              style: TextStyle(
                color: context.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),

            // Change Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: changeColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context, String symbol) {
    return Center(
      child: Text(
        symbol.length > 3 ? symbol.substring(0, 3) : symbol,
        style: TextStyle(
          color: context.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
