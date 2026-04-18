import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionHistoryList extends GetView<SimulationController> {
  const TransactionHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure transactions are fetched
    if (controller.transactions.isEmpty && !controller.isLoading.value) {
      controller.fetchTransactions();
    }

    return Obx(() {
      if (controller.isLoading.value && controller.transactions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 80,
                color: context.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                context.s.sim_no_transactions,
                style: TextStyle(
                  fontSize: 18,
                  color: context.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.s.sim_trading_history_desc,
                style: TextStyle(
                  fontSize: 14,
                  color: context.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.transactions.length,
        itemBuilder: (context, index) {
          final transaction = controller.transactions[index];
          final isBuy = transaction.isBuy;
          final color = isBuy ? AppColors.candleGreen : AppColors.candleRed;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Type and Symbol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.type.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (transaction.isAutoProtection) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  context.s.sim_auto,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                        Text(
                          transaction.symbol,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                      color: color,
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: context.onSurface.withOpacity(0.1)),
                const SizedBox(height: 12),

                // Transaction Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DetailItem(
                      label: context.s.sim_quantity,
                      value: transaction.quantity.toStringAsFixed(4),
                      context: context,
                    ),
                    _DetailItem(
                      label: context.s.sim_price,
                      value: NumberFormat('#,##0.00').format(transaction.price),
                      context: context,
                    ),
                    _DetailItem(
                      label: context.s.sim_total_capital,
                      value: NumberFormat(
                        '#,##0.00',
                      ).format(transaction.totalValue),
                      context: context,
                      isTotal: true,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Timestamp
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: context.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • HH:mm',
                      ).format(transaction.createdAt),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.onSurface.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  final bool isTotal;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.context,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isTotal
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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
            color: isTotal ? context.primary : context.onSurface,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
