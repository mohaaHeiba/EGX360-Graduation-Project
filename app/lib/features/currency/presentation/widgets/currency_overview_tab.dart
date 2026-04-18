import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:flutter/material.dart';

Widget buildCurrencyStatsTab(
  Map<String, dynamic> stockData,
  List<CandleEntity> candles, {
  String? symbol,
  double? livePrevClose,
  double rate = 1.0,
}) {
  // Calculate stats
  String open = "-";
  String high = "-";
  String low = "-";

  if (candles.isNotEmpty) {
    final lastCandle = candles.last;
    open = PriceFormatter.formatPrice(lastCandle.open * rate);

    final highVal =
        candles.map((e) => e.high).reduce((a, b) => a > b ? a : b) * rate;
    high = PriceFormatter.formatPrice(highVal);

    final lowVal =
        candles.map((e) => e.low).reduce((a, b) => a < b ? a : b) * rate;
    low = PriceFormatter.formatPrice(lowVal);
  }

  return Builder(
    builder: (context) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Key Statistics", context),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard("Open", open, Icons.login, context),
              _buildStatCard(
                "Prev Close",
                livePrevClose != null
                    ? PriceFormatter.formatPrice(livePrevClose * rate)
                    : (stockData['prev_close'] != null
                          ? PriceFormatter.formatPrice(
                              (stockData['prev_close'] as num) * rate,
                            )
                          : "-"),
                Icons.history,
                context,
              ),
              _buildStatCard(
                "High",
                high,
                Icons.arrow_upward,
                context,
                valueColor: Colors.greenAccent,
              ),
              _buildStatCard(
                "Low",
                low,
                Icons.arrow_downward,
                context,
                valueColor: Colors.redAccent,
              ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _buildSectionTitle(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      title,
      style: context.textStyles.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.onSurface,
      ),
    ),
  );
}

Widget _buildStatCard(
  String title,
  String value,
  IconData icon,
  BuildContext context, {
  Color? valueColor,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.onSurface.withOpacity(0.05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: context.onSurface.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              title,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? context.onSurface,
          ),
        ),
      ],
    ),
  );
}
