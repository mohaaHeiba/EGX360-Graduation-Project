import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class QuickIndicatorsSection extends GetView<HomeController> {
  const QuickIndicatorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Gold Card
          _buildGoldCard(context),
          const SizedBox(width: 12),
          // Silver Card
          _buildSilverCard(context),
          const SizedBox(width: 12),

          // Currency Cards
          Obx(() {
            final prices = controller.currencyPrices;
            final s = context.s;
            return Row(
              children: [
                _buildCurrencyCard(
                  context,
                  'USDEGP',
                  s.usd_label,
                  Icons.attach_money,
                  Colors.green,
                  prices['USDEGP'],
                ),
                const SizedBox(width: 12),
                _buildCurrencyCard(
                  context,
                  'EUREGP',
                  s.eur_label,
                  Icons.euro,
                  Colors.blue,
                  prices['EUREGP'],
                ),
                const SizedBox(width: 12),
                _buildCurrencyCard(
                  context,
                  'GBPEGP',
                  s.gbp_label,
                  Icons.currency_pound,
                  Colors.purple,
                  prices['GBPEGP'],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(
    BuildContext context,
    String symbol,
    String name,
    IconData icon,
    Color color,
    double? price,
  ) {
    final formattedPrice = price != null
        ? '${price.toStringAsFixed(2)} EGP'
        : '-- EGP';

    return GestureDetector(
      onTap: () {
        final stock = StockModel(
          id: symbol,
          symbol: symbol,
          companyNameEn: name,
          sector: 'Currencies',
          currentPrice: price,
        );
        controller.openStockDetails(stock);
      },
      child: _IndicatorCard(
        title: '$name/EGP',
        value: formattedPrice,
        icon: icon,
        color: color,
        isLoading: controller.isLoading.value && price == null,
      ),
    );
  }

  Widget _buildGoldCard(BuildContext context) {
    return Obx(() {
      final materialPrice = controller.materialPrice.value;
      final price = materialPrice?.p21Sell ?? 0.0;
      final formattedPrice = NumberFormat.currency(
        symbol: '',
        decimalDigits: 0,
      ).format(price);
      final s = context.s;

      return GestureDetector(
        onTap: () {
          controller.openGoldDetails();
        },
        child: _IndicatorCard(
          title: s.gold_21k_title,
          value: '$formattedPrice EGP',
          icon: Icons.monetization_on_outlined,
          color: const Color(0xFFFFD700), // Gold color
          isLoading: controller.isLoading.value && materialPrice == null,
        ),
      );
    });
  }

  Widget _buildSilverCard(BuildContext context) {
    return Obx(() {
      final materialPrice = controller.materialPrice.value;
      final price = materialPrice?.silver999Sell ?? 0.0;
      final formattedPrice = NumberFormat.currency(
        symbol: '',
        decimalDigits: 0,
      ).format(price);
      final s = context.s;

      return GestureDetector(
        onTap: () {
          controller.openSilverDetails();
        },
        child: _IndicatorCard(
          title: s.silver_999_title,
          value: '$formattedPrice EGP',
          icon: Icons.blur_on, // Or another icon for Silver
          color: const Color(0xFFC0C0C0), // Silver color
          isLoading: controller.isLoading.value && materialPrice == null,
        ),
      );
    });
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _IndicatorCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: context.onSurface.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            SizedBox(
              height: 20,
              width: 80,
              child: LinearProgressIndicator(
                color: color.withOpacity(0.5),
                backgroundColor: context.surface,
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: context.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}
