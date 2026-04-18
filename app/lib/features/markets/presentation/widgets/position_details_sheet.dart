import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';

/// Widget to display position details dialog
class PositionDetailsSheet extends StatelessWidget {
  final dynamic holding;
  final double currentPrice;
  final bool isPositive;
  final double profitLoss;
  final double plPercent;

  const PositionDetailsSheet({
    super.key,
    required this.holding,
    required this.currentPrice,
    required this.isPositive,
    required this.profitLoss,
    required this.plPercent,
  });

  static void show(
    BuildContext context, {
    required dynamic holding,
    required double currentPrice,
    required bool isPositive,
    required double profitLoss,
    required double plPercent,
  }) {
    showDialog(
      context: context,
      builder: (context) => PositionDetailsSheet(
        holding: holding,
        currentPrice: currentPrice,
        isPositive: isPositive,
        profitLoss: profitLoss,
        plPercent: plPercent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.onSurface.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.s.position_my_position,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: context.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Position Details
            _buildDetailRow(
              context,
              context.s.position_shares_owned,
              holding.quantity.toStringAsFixed(2),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              context.s.position_avg_buy_price,
              PriceFormatter.formatPrice(holding.averagePrice),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              context.s.position_current_price,
              PriceFormatter.formatPrice(currentPrice),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              context.s.position_total_cost,
              PriceFormatter.formatPrice(
                holding.quantity * holding.averagePrice,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              context.s.position_current_value,
              PriceFormatter.formatPrice(holding.quantity * currentPrice),
            ),
            const SizedBox(height: 12),
            // Profit/Loss
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.s.position_total_pl,
                  style: TextStyle(
                    color: context.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${PriceFormatter.formatPrice(profitLoss)}',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${plPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
