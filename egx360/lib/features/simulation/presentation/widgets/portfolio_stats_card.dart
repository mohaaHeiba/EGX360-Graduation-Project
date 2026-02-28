import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PortfolioStatsCard extends StatelessWidget {
  final SimulationController controller;

  const PortfolioStatsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final wallet = controller.wallet.value;
      final balance = wallet?.balance ?? 0.0;
      final totalValue = controller.totalPortfolioValue;
      final totalPL = controller.totalProfitLoss;
      final totalPLPercent = controller.totalProfitLossPercent;
      final isPositive = totalPL >= 0;
      final plColor = isPositive ? AppColors.candleGreen : AppColors.candleRed;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.primary.withOpacity(0.1),
              context.surface.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.onSurface.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Portfolio Value
            Text(
              context.s.sim_total_portfolio_value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.s.search_egp,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  NumberFormat('#,##0.00').format(totalValue),
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: plColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${NumberFormat('#,##0.00').format(totalPL)} ${context.s.search_egp} (${isPositive ? '+' : ''}${totalPLPercent.toStringAsFixed(2)}%)',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: plColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: context.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: context.s.sim_available_cash,
                    value:
                        '${context.s.search_egp} ${NumberFormat('#,##0.00').format(balance)}',
                    icon: Icons.account_balance_wallet,
                    color: context.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.onSurface.withOpacity(0.1),
                ),
                Expanded(
                  child: _StatItem(
                    label: context.s.sim_positions,
                    value: '${controller.positionsCount}',
                    icon: Icons.layers,
                    color: context.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.onSurface.withOpacity(0.6),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
