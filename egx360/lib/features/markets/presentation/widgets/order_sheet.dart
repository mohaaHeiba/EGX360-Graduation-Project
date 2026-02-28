import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSheet extends StatefulWidget {
  final bool isBuy;
  final String symbol;
  final double currentPrice;

  const OrderSheet({
    super.key,
    required this.isBuy,
    required this.symbol,
    required this.currentPrice,
  });

  @override
  State<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<OrderSheet> {
  bool _isMarket = true;
  final TextEditingController _qtyController = TextEditingController();
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.currentPrice.toStringAsFixed(3),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isBuy ? AppColors.candleGreen : AppColors.candleRed;
    final action = widget.isBuy ? context.s.order_buy : context.s.order_sell;
    final currentPrice = widget.currentPrice;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$action ${widget.symbol}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Order Type
          Row(
            children: [
              _buildTypeButton(context.s.order_market, _isMarket, color),
              const SizedBox(width: 12),
              _buildTypeButton(context.s.order_limit, !_isMarket, color),
            ],
          ),
          const SizedBox(height: 24),

          // Inputs
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: context.onSurface),
            decoration: InputDecoration(
              labelText: context.s.order_quantity,
              labelStyle: TextStyle(
                color: context.onSurface.withValues(alpha: 0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.onSurface.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
            ),
          ),
          if (!_isMarket) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: context.onSurface),
              decoration: InputDecoration(
                labelText: context.s.order_price,
                labelStyle: TextStyle(
                  color: context.onSurface.withValues(alpha: 0.6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: color),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Summary
          // Summary
          _buildSummary(context, currentPrice),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(context, action, color),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double currentPrice) {
    // Try to get simulation controller
    SimulationController? simController;
    try {
      simController = Get.find<SimulationController>();
    } catch (e) {
      // Controller not initialized yet
    }

    if (simController == null) {
      return Text(
        context.s.order_est_total("0.00"),
        style: TextStyle(
          color: context.onSurface.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      );
    }

    return Obx(() {
      final balance = simController!.wallet.value?.balance ?? 0;
      final qty = double.tryParse(_qtyController.text) ?? 0;
      final price = _isMarket
          ? currentPrice
          : (double.tryParse(_priceController.text) ?? currentPrice);
      final total = qty * price;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.s.order_est_total(total.toStringAsFixed(2)),
            style: TextStyle(
              color: context.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.s.order_available_balance(balance.toStringAsFixed(2)),
            style: TextStyle(
              color: context.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButton(BuildContext context, String action, Color color) {
    // Try to get simulation controller
    SimulationController? simController;
    try {
      simController = Get.find<SimulationController>();
    } catch (e) {
      // Controller not initialized yet
    }

    if (simController == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.s.order_sim_not_available),
              backgroundColor: AppColors.error,
            ),
          );
        },
        child: Text(
          context.s.order_place_order(action.toUpperCase()),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Obx(() {
      final isExecuting = simController!.isExecutingTrade.value;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isExecuting ? null : () => _executeTrade(context, action),
        child: isExecuting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                context.s.order_place_order(action.toUpperCase()),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    });
  }

  Future<void> _executeTrade(BuildContext context, String action) async {
    final qty = double.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.s.order_valid_qty),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = _isMarket
        ? widget.currentPrice
        : (double.tryParse(_priceController.text) ?? widget.currentPrice);

    final symbol = widget.symbol;
    final isBuy = widget.isBuy;

    try {
      final simController = Get.find<SimulationController>();
      await simController.executeTrade(
        symbol: symbol,
        type: isBuy ? 'buy' : 'sell',
        quantity: qty,
        price: price,
      );

      // Close the order sheet
      if (context.mounted) Navigator.pop(context);

      // For BUY: show protection setup dialog
      // For SELL: show success snackbar
      if (isBuy) {
        _showProtectionSetupDialog(symbol);
      } else {
        Get.snackbar(
          context.s.order_trade_executed,
          context.s.order_sold_msg(qty, symbol),
          backgroundColor: AppColors.candleGreen,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showProtectionSetupDialog(String symbol) {
    final alertPct = 5.0.obs;
    final liquidationPct = 10.0.obs;
    final autoSellEnabled = true.obs;
    final isSaving = false.obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield, color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.s.order_protection_title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.s.order_protection_desc(symbol),
                      style: TextStyle(
                        fontSize: 12,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              // Alert slider
              _buildDialogSlider(
                label: context.s.order_alert_threshold,
                value: alertPct.value,
                min: 1,
                max: 25,
                color: Colors.amber,
                onChanged: (v) {
                  alertPct.value = v;
                  if (autoSellEnabled.value && liquidationPct.value < v) {
                    liquidationPct.value = v;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Auto-sell toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: autoSellEnabled.value
                      ? AppColors.candleRed.withOpacity(0.05)
                      : Get.theme.colorScheme.onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: autoSellEnabled.value
                        ? AppColors.candleRed.withOpacity(0.15)
                        : Get.theme.colorScheme.onSurface.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel,
                          size: 16,
                          color: autoSellEnabled.value
                              ? AppColors.candleRed
                              : Get.theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.s.order_auto_sell,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: autoSellEnabled.value
                                ? Get.theme.colorScheme.onSurface
                                : Get.theme.colorScheme.onSurface.withOpacity(
                                    0.5,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: autoSellEnabled.value,
                      activeColor: AppColors.candleRed,
                      onChanged: (v) => autoSellEnabled.value = v,
                    ),
                  ],
                ),
              ),

              // Liquidation slider — only if auto-sell is ON
              if (autoSellEnabled.value) ...[
                const SizedBox(height: 12),
                _buildDialogSlider(
                  label: context.s.order_auto_sell_threshold,
                  value: liquidationPct.value,
                  min: alertPct.value,
                  max: 50,
                  color: AppColors.candleRed,
                  onChanged: (v) => liquidationPct.value = v,
                ),
              ],
              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        autoSellEnabled.value
                            ? context.s.order_protection_info_both(
                                alertPct.value.toStringAsFixed(1),
                                liquidationPct.value.toStringAsFixed(1),
                              )
                            : context.s.order_protection_info_alert(
                                alertPct.value.toStringAsFixed(1),
                              ),
                        style: TextStyle(
                          fontSize: 11,
                          color: Get.theme.colorScheme.onSurface.withOpacity(
                            0.6,
                          ),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Skip button
            TextButton(
              onPressed: isSaving.value
                  ? null
                  : () {
                      Get.back();
                      Get.snackbar(
                        context.s.order_trade_executed,
                        context.s.order_bought_msg(symbol),
                        backgroundColor: AppColors.candleGreen,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
              child: Text(
                context.s.order_skip,
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),

            // Enable button
            ElevatedButton.icon(
              onPressed: isSaving.value
                  ? null
                  : () async {
                      isSaving.value = true;
                      try {
                        final controller = Get.find<SimulationController>();
                        await controller.saveProtectionRule(
                          symbol: symbol,
                          alertPercentage: alertPct.value,
                          liquidationPercentage: autoSellEnabled.value
                              ? liquidationPct.value
                              : 10.0,
                          isAlertEnabled: true,
                          isSellEnabled: autoSellEnabled.value,
                        );
                        Get.back();
                        final msg = autoSellEnabled.value
                            ? context.s.order_msg_both(
                                alertPct.value.toStringAsFixed(1),
                                liquidationPct.value.toStringAsFixed(1),
                              )
                            : context.s.order_msg_alert(
                                alertPct.value.toStringAsFixed(1),
                              );
                        Get.snackbar(
                          context.s.order_protection_enabled,
                          context.s.order_monitoring_msg(symbol, msg),
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 3),
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to save rule: $e',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } finally {
                        isSaving.value = false;
                      }
                    },
              icon: isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.shield, size: 16),
              label: Text(
                isSaving.value
                    ? context.s.order_saving
                    : context.s.order_enable_protection,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDialogSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${value.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withOpacity(0.15),
            overlayColor: color.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).round().clamp(1, 100),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isMarket = label == "Market"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? color
                  : context.onSurface.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : context.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
