import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/simulation/domain/entities/holding_entity.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:egx/features/simulation/presentation/widgets/protection_rule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HoldingListItem extends StatelessWidget {
  final HoldingEntity holding;
  final SimulationController controller;

  const HoldingListItem({
    super.key,
    required this.holding,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currentPrice =
        controller.currentPrices[holding.symbol] ?? holding.averagePrice;
    final pl = controller.getHoldingProfitLoss(holding);
    final plPercent = controller.getHoldingProfitLossPercent(holding);
    final isPositive = pl >= 0;
    final plColor = isPositive ? AppColors.candleGreen : AppColors.candleRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Symbol and Current Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      holding.symbol,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.symbol,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${holding.quantity.toStringAsFixed(4)} ${context.s.sim_shares_unit}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Protection Shield Button
                  Obx(() {
                    final hasRule = controller.hasProtectionRule(
                      holding.symbol,
                    );
                    final rule = controller.getProtectionRule(holding.symbol);
                    final isActive = hasRule && (rule?.isActive ?? false);

                    return GestureDetector(
                      onTap: () =>
                          ProtectionRuleSheet.show(context, holding.symbol),
                      child: Tooltip(
                        message: isActive
                            ? context.s.sim_protection_active(
                                rule!.alertPercentage.toStringAsFixed(0),
                                rule.liquidationPercentage.toStringAsFixed(0),
                              )
                            : context.s.sim_set_protection,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.orange.withOpacity(0.1)
                                : context.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isActive ? Icons.shield : Icons.shield_outlined,
                            size: 18,
                            color: isActive
                                ? Colors.orange
                                : context.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat(
                          '#,##0.00',
                        ).format(holding.quantity * currentPrice),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.s.search_egp,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: context.onSurface.withOpacity(0.1)),
          const SizedBox(height: 12),

          // Price Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(
                label: context.s.sim_avg_price,
                value: NumberFormat('#,##0.00').format(holding.averagePrice),
                context: context,
              ),
              _InfoItem(
                label: context.s.sim_current_price,
                value: NumberFormat('#,##0.00').format(currentPrice),
                context: context,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.s.sim_pl,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.onSurface.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}${NumberFormat('#,##0.00').format(pl)}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: plColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${plPercent.toStringAsFixed(2)}%',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: plColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
