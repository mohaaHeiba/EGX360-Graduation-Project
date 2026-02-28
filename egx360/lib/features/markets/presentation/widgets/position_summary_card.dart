import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PositionSummaryCard extends StatelessWidget {
  const PositionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Get Controllers
      final marketsController = Get.find<MarketsController>();
      SimulationController? simController;
      try {
        simController = Get.find<SimulationController>();
      } catch (e) {
        return const SizedBox.shrink();
      }

      // 2. Get Selected Stock & Holdings
      final selectedStock = marketsController.selectedStock.value;
      if (selectedStock == null) return const SizedBox.shrink();

      final holding = simController.holdings.firstWhereOrNull(
        (h) => h.symbol == selectedStock.symbol,
      );

      // 3. If not held, hide card
      if (holding == null) return const SizedBox.shrink();

      // 4. Calculate Live P&L
      // Use MarketsController's live price if available, otherwise fallback
      final currentPrice = marketsController.candles.isNotEmpty
          ? marketsController.candles.last.close
          : (simController.currentPrices[holding.symbol] ??
                holding.averagePrice);

      final currentValue = holding.quantity * currentPrice;
      final costBasis = holding.quantity * holding.averagePrice;
      final profitLoss = currentValue - costBasis;
      final profitLossPercent = costBasis == 0
          ? 0.0
          : (profitLoss / costBasis) * 100;
      final isPositive = profitLoss >= 0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Position Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.s.position_my_position,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      context.s.position_shares(
                        holding.quantity.toStringAsFixed(2),
                      ),
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@ ${PriceFormatter.formatPrice(holding.averagePrice)}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Right: P&L Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.s.position_pl_short,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${PriceFormatter.formatPrice(profitLoss)}',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: isPositive
                            ? AppColors.candleGreen
                            : AppColors.candleRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isPositive
                                    ? AppColors.candleGreen
                                    : AppColors.candleRed)
                                .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: isPositive
                              ? AppColors.candleGreen
                              : AppColors.candleRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
