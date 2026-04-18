import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/markets/presentation/widgets/desktop/technical_gauge.dart';
import 'package:egx/features/markets/presentation/widgets/shared/seasonals_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StockDetailsPanel extends GetView<MarketsController> {
  const StockDetailsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stock = controller.selectedStock.value;
      final dailyCandle = controller.dailyCandle.value;

      if (stock == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              context.s.details_no_asset,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      }

      // Calculate price and change
      final close = dailyCandle?.close ?? stock.currentPrice ?? 0.0;
      final prevClose = stock.prevClose ?? dailyCandle?.open ?? 0.0;
      final change = prevClose != 0 ? close - prevClose : 0.0;
      final changePercent = prevClose != 0 ? (change / prevClose) * 100 : 0.0;
      final isPositive = change >= 0;
      final changeColor = isPositive
          ? AppColors.candleGreen
          : AppColors.candleRed;

      // Calculate stats
      final volume = dailyCandle?.volume ?? 0;
      final marketCap = stock.totalShares != null
          ? stock.totalShares! * close
          : 0.0;
      final volumeToMarketCap = marketCap > 0 ? volume / marketCap : 0.0;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Symbol and Name
            Text(
              '${stock.symbol} / U.S. Dollar',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  context.s.details_spot,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('•', style: TextStyle(color: Colors.grey[400])),
                ),
                Text(
                  stock.sector ??
                      stock.assetType ??
                      context.s.details_asset_fallback,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(close),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'USD',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.8,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Market Status
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.isMarketOpen
                        ? AppColors.candleGreen
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  controller.isMarketOpen
                      ? context.s.details_market_open
                      : context.s.details_market_closed,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),

            // const SizedBox(height: 20),

            // // Market News/Update Card
            // MarketNewsCard(
            //   title: _getMarketNewsTitle(stock.symbol, changePercent),
            //   icon: Icons.trending_up_rounded,
            //   onTap: () {
            //     // TODO: Navigate to news details
            //   },
            // ),
            const SizedBox(height: 24),

            // Key stats Section Header
            Text(
              context.s.details_key_stats,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[200],
              ),
            ),

            const SizedBox(height: 14),

            // Stats Grid - Two Column Layout
            _buildStatRow(
              context,
              context.s.details_volume,
              _formatVolume(volume),
            ),
            _buildStatRow(
              context,
              context.s.details_avg_volume_30d,
              _formatVolume((volume * 0.85).toInt()), // Mock calculation
            ),
            _buildStatRow(
              context,
              context.s.details_volume_24h,
              _formatVolume(volume),
            ),
            _buildStatRow(
              context,
              context.s.details_market_cap,
              _formatLargeNumber(marketCap),
            ),
            _buildStatRow(
              context,
              context.s.details_fully_diluted_mc,
              _formatLargeNumber(marketCap),
            ),
            _buildStatRow(
              context,
              context.s.details_vol_mc_ratio,
              volumeToMarketCap.toStringAsFixed(4),
            ),
            if (stock.totalShares != null)
              _buildStatRow(
                context,
                context.s.details_circulating_supply,
                _formatLargeNumber(stock.totalShares!.toDouble()),
              ),

            // const SizedBox(height: 4),

            // Collapse/Expand button
            // Center(
            //   child: IconButton(
            //     onPressed: () {
            //       // TODO: Implement expand/collapse
            //     },
            //     icon: Icon(
            //       Icons.keyboard_arrow_up_rounded,
            //       color: Colors.grey[400],
            //     ),
            //     iconSize: 20,
            //   ),
            // ),

            if (controller.aiPrediction.value != null) ...[
              const SizedBox(height: 16),
              Text(
                'AI Prediction',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TechnicalGauge(
                value: controller.aiPrediction.value!.score,
                isAi: true,
                customRecommendation:
                    'AI: ${controller.aiPrediction.value!.recommendation}',
                onMoreTap: () {
                  // TODO: Navigate to detailed AI prediction
                },
              ),
            ],

            const SizedBox(height: 24),
            
            // Seasonals Section
            const SeasonalsChart(),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return NumberFormat('#,###').format(price.round());
    } else if (price >= 1) {
      return price.toStringAsFixed(3);
    } else {
      return price.toStringAsFixed(4);
    }
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    }
    return volume.toString();
  }

  String _formatLargeNumber(double number) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(2)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }
}
