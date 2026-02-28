import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/currency/presentation/controllers/currency_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildCurrencyCalculatorTab(CurrencyDetailsController controller) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency Converter',
          style: TextStyle(
            color: Get.context!.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _CurrencyConverter(controller: controller),
      ],
    ),
  );
}

class _CurrencyConverter extends StatefulWidget {
  final CurrencyDetailsController controller;

  const _CurrencyConverter({required this.controller});

  @override
  State<_CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<_CurrencyConverter> {
  late TextEditingController _foreignController;
  late TextEditingController _localController;

  // To prevent loops when updating text fields
  bool _isUpdatingForeign = false;
  bool _isUpdatingLocal = false;

  @override
  void initState() {
    super.initState();
    _foreignController = TextEditingController(text: '1');
    _localController = TextEditingController();

    // Initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocalFromForeign('1');
    });
  }

  @override
  void dispose() {
    _foreignController.dispose();
    _localController.dispose();
    super.dispose();
  }

  void _updateLocalFromForeign(String value) {
    if (_isUpdatingLocal) return;

    final amount = double.tryParse(value);
    if (amount != null) {
      final rate = widget.controller.currentRate.value;
      final result = amount * rate;

      _isUpdatingForeign = true;
      _localController.text = result.toStringAsFixed(2);
      _isUpdatingForeign = false;
    } else {
      _isUpdatingForeign = true;
      _localController.text = '';
      _isUpdatingForeign = false;
    }
  }

  void _updateForeignFromLocal(String value) {
    if (_isUpdatingForeign) return;

    final amount = double.tryParse(value);
    if (amount != null) {
      final rate = widget.controller.currentRate.value;
      if (rate == 0) return;

      final result = amount / rate;

      _isUpdatingLocal = true;
      _foreignController.text = result.toStringAsFixed(2);
      _isUpdatingLocal = false;
    } else {
      _isUpdatingLocal = true;
      _foreignController.text = '';
      _isUpdatingLocal = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localCode = 'EGP';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Obx(() {
        // Re-calculate if rate changes and fields are not empty
        // But be careful not to overwrite user input while typing
        // Just use the current rate for calculations
        final rate = widget.controller.currentRate.value;
        final symbol = widget.controller.symbol.value;
        final foreignCode = symbol.length >= 3 ? symbol.substring(0, 3) : 'USD';

        return Column(
          children: [
            // Foreign Currency Input
            _buildCurrencyInput(
              context,
              controller: _foreignController,
              code: foreignCode,
              onChanged: _updateLocalFromForeign,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.swap_vert_circle_outlined,
                      color: context.primary,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.1)),
                  ),
                ],
              ),
            ),

            // Local Currency Input
            _buildCurrencyInput(
              context,
              controller: _localController,
              code: localCode,
              onChanged: _updateForeignFromLocal,
            ),

            const SizedBox(height: 20),

            // Rate Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: context.primary),
                  const SizedBox(width: 8),
                  Text(
                    '1 $foreignCode = ${rate.toStringAsFixed(2)} $localCode',
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrencyInput(
    BuildContext context, {
    required TextEditingController controller,
    required String code,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: TextStyle(
            color: context.onSurface.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixText: code,
            suffixStyle: TextStyle(
              color: context.onSurface.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
