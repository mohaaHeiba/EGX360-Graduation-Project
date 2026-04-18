import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Widget buildSimulationCard(BuildContext context) {
  // Try to get simulation controller
  SimulationController? simController;
  try {
    simController = Get.find<SimulationController>();
  } catch (e) {
    // Controller not initialized yet
  }

  return GestureDetector(
    onTap: () {
      // Navigate to Portfolio page
      Get.toNamed(AppPages.portfolioPage);
    },
    child: simController != null
        ? Obx(() {
            final balance = simController?.wallet.value?.balance ?? 0.0;
            final totalPL = simController?.totalProfitLoss ?? 0.0;
            final totalPLPercent = simController?.totalProfitLossPercent ?? 0.0;
            final positionsCount = simController?.positionsCount ?? 0;

            return _buildCardContent(
              context,
              balance,
              totalPL,
              totalPLPercent,
              positionsCount,
            );
          })
        : _buildCardContent(
            context,
            100000.0, // Default/Static balance
            0.0,
            0.0,
            0,
          ),
  );
}

Widget _buildCardContent(
  BuildContext context,
  double balance,
  double totalPL,
  double totalPLPercent,
  int positionsCount,
) {
  final theme = context;
  final isPositive = totalPL >= 0;

  return Container(
    decoration: BoxDecoration(
      color: theme.surface.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: theme.onSurface.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: context.surface.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: theme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.s.simulation_portfolio,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.onSurface.withOpacity(0.4),
                size: 14,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---------- Balance ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EGP',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              // Animated Balance
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: balance, end: balance),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    NumberFormat('#,##0.00').format(value),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(
                    0.2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    Text(
                      '${totalPLPercent.abs().toStringAsFixed(2)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---------- Stats ----------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSimStatItem(
                    context,
                    context.s.simulation_total_pl,
                    '${isPositive ? '+' : ''}EGP ${NumberFormat('#,##0').format(totalPL.abs())}',
                    isPositive ? Colors.green : Colors.red,
                    Icons.trending_up_rounded,
                  ),
                ),
                _divider(theme),
                Expanded(
                  child: _buildSimStatItem(
                    context,
                    context.s.simulation_positions,
                    '$positionsCount',
                    theme.primary,
                    Icons.layers_rounded,
                  ),
                ),
                _divider(theme),
                Expanded(
                  child: _buildSimStatItem(
                    context,
                    context.s.simulation_available_cash,
                    NumberFormat('#,##0').format(balance),
                    theme.onSurface.withOpacity(0.7),
                    Icons.attach_money_rounded,
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

Widget _divider(BuildContext context) =>
    Container(width: 1, height: 40, color: context.onSurface.withOpacity(0.2));

Widget _buildSimStatItem(
  BuildContext context,
  String label,
  String value,
  Color color,
  IconData icon,
) {
  return Column(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(
        value,
        style: context.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
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
