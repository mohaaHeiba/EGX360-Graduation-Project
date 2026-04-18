import 'dart:math';

import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/markets/presentation/widgets/desktop/technical_gauge.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:egx/generated/l10n.dart';

import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/assets/presentation/widgets/shared/week_range_card.dart';

Widget buildOverviewTab(
  Map<String, dynamic> stockData,
  List<CandleEntity> candles, {
  String? symbol,
  MaterialPriceEntity? materialPrice,
  double? livePrevClose,
  bool isIndex = false,
  bool isEgp = true,
  bool isCurrency = false,
  double rate = 1.0,
  AiPrediction? aiPrediction,
}) {
  // --- Calculations ---
  String open = "-";
  String high = "-";
  String low = "-";
  String volume = "-";
  String mktCap = "-";
  String avgVolume = "-";
  String volatility = "-";
  double? week52LowValue;
  double? week52HighValue;
  double? currentPriceValue;

  final effectiveRate = isEgp ? rate : 1.0;

  if (candles.isNotEmpty) {
    final lastCandle = candles.last;
    open = PriceFormatter.formatPrice(lastCandle.open * effectiveRate);

    final highVal =
        candles.map((e) => e.high).reduce((a, b) => a > b ? a : b) *
        effectiveRate;
    high = PriceFormatter.formatPrice(highVal);

    final lowVal =
        candles.map((e) => e.low).reduce((a, b) => a < b ? a : b) *
        effectiveRate;
    low = PriceFormatter.formatPrice(lowVal);

    final totalVolume = candles.fold<int>(0, (sum, item) => sum + item.volume);
    volume = PriceFormatter.formatCompactPrice(totalVolume.toDouble());

    if (stockData['total_shares'] != null) {
      final shares = stockData['total_shares'] as int;
      final cap = shares * lastCandle.close * effectiveRate;
      mktCap = PriceFormatter.formatCompactPrice(cap);
    }

    // 52-Week Range: lowest low to highest high from all candles
    final week52Low =
        candles.map((e) => e.low).reduce((a, b) => a < b ? a : b) *
        effectiveRate;
    final week52High =
        candles.map((e) => e.high).reduce((a, b) => a > b ? a : b) *
        effectiveRate;

    // Store values for visualization
    week52LowValue = week52Low;
    week52HighValue = week52High;
    currentPriceValue = lastCandle.close * effectiveRate;

    // Average Volume: mean of all candle volumes
    final avgVol = totalVolume / candles.length;
    avgVolume = PriceFormatter.formatCompactPrice(avgVol);

    // Volatility: Standard deviation of daily returns (percentage)
    if (candles.length > 1) {
      List<double> returns = [];
      for (int i = 1; i < candles.length; i++) {
        final prevClose = candles[i - 1].close;
        final currentClose = candles[i].close;
        if (prevClose > 0) {
          final dailyReturn = ((currentClose - prevClose) / prevClose) * 100;
          returns.add(dailyReturn);
        }
      }

      if (returns.isNotEmpty) {
        final mean = returns.reduce((a, b) => a + b) / returns.length;
        final variance =
            returns
                .map((r) => (r - mean) * (r - mean))
                .reduce((a, b) => a + b) /
            returns.length;
        final stdDev = sqrt(variance);
        volatility = "${stdDev.toStringAsFixed(2)}%";
      }
    }

    // RSI: Relative Strength Index (14-period)
    if (candles.length >= 15) {
      final period = 14;
      List<double> gains = [];
      List<double> losses = [];

      // Calculate gains and losses for the period
      for (int i = candles.length - period; i < candles.length; i++) {
        if (i > 0) {
          final change = candles[i].close - candles[i - 1].close;
          if (change > 0) {
            gains.add(change);
            losses.add(0);
          } else {
            gains.add(0);
            losses.add(change.abs());
          }
        }
      }
    }
  }

  String description = stockData['description'] ?? "No description available.";
  List<String> constituents = [];

  if (isIndex && description.isNotEmpty && description.contains('--split--')) {
    final parts = description.split('--split--');

    // الجزء الأول: بنحدث قيمة الـ description بالجزء اللي قبل split
    description = parts[0].trim();

    // الجزء الثاني: شغلك القديم زي ما هو بدون أي تغيير
    if (parts.length > 1) {
      constituents = parts[1].split(',').map((e) => e.trim()).toList();
    }
  }

  return Builder(
    builder: (context) {
      final isDarkMode = context.isDarkMode;

      final localizedDescription = description.isNotEmpty
          ? description
          : (stockData['description'] ??
                S.of(context).asset_details_no_description);
      // Build stat cards list with subsections
      final List<Widget> allContent = [];

      // Market Data Subsection (includes Activity)
      allContent.add(
        _buildSubsectionTitle(S.of(context).asset_details_market_data, context),
      );
      allContent.add(const SizedBox(height: 12));

      final marketDataCards = [
        _buildStatCard(
          S.of(context).asset_details_open,
          open,
          Icons.login,
          context,
        ),
        _buildStatCard(
          S.of(context).asset_details_prev_close,
          livePrevClose != null
              ? PriceFormatter.formatPrice(livePrevClose * effectiveRate)
              : (stockData['prev_close'] != null
                    ? PriceFormatter.formatPrice(
                        (stockData['prev_close'] as num) * effectiveRate,
                      )
                    : "-"),
          Icons.history,
          context,
        ),
        _buildStatCard(
          S.of(context).asset_details_high,
          high,
          Icons.arrow_upward,
          context,
          valueColor: Colors.greenAccent,
        ),
        _buildStatCard(
          S.of(context).asset_details_low,
          low,
          Icons.arrow_downward,
          context,
          valueColor: Colors.redAccent,
        ),
        if (!isCurrency)
          _buildStatCard(
            S.of(context).asset_details_volume,
            volume,
            Icons.show_chart,
            context,
          ),
        if (!isCurrency)
          _buildStatCard(
            S.of(context).asset_details_avg_volume,
            avgVolume,
            Icons.bar_chart,
            context,
          ),
      ];

      allContent.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: marketDataCards.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 100.h,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => marketDataCards[index],
        ),
      );

      // Technicals Subsection (includes Valuation)
      if (!isCurrency) {
        allContent.add(const SizedBox(height: 24));
        allContent.add(
          _buildSubsectionTitle(
            S.of(context).asset_details_technicals,
            context,
          ),
        );
        allContent.add(const SizedBox(height: 12));

        final technicalsCards = [
          _buildStatCard(
            S.of(context).asset_details_volatility,
            volatility,
            Icons.trending_flat,
            context,
            valueColor: Colors.purpleAccent,
          ),
          if (!isIndex)
            _buildStatCard(
              S.of(context).asset_details_mkt_cap,
              mktCap,
              Icons.pie_chart,
              context,
              valueColor: Colors.blueAccent,
            ),
        ];

        allContent.add(
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: technicalsCards.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 100.h,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) => technicalsCards[index],
          ),
        );

        // AI Prediction Gauge
        if (aiPrediction != null) {
          allContent.add(const SizedBox(height: 20));
          allContent.add(
            TechnicalGauge(
              value: aiPrediction.score,
              isAi: true,
              customRecommendation: 'AI: ${aiPrediction.recommendation}',
              display: false,
            ),
          );
        }
      }

      // Performance Subsection - 52-Week Range Visualization
      if (!isCurrency && week52LowValue != null && week52HighValue != null) {
        allContent.add(const SizedBox(height: 24));
        allContent.add(
          _buildSubsectionTitle(
            S.of(context).asset_details_performance,
            context,
          ),
        );
        allContent.add(const SizedBox(height: 12));
        allContent.add(
          WeekRangeCard(
            lowValue: week52LowValue,
            highValue: week52HighValue,
            currentValue: currentPriceValue,
            lowLabel: PriceFormatter.formatPrice(week52LowValue),
            highLabel: PriceFormatter.formatPrice(week52HighValue),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(S.of(context).asset_details_key_stats, context),
          AppGaps.h16,
          ...allContent,

          if ((symbol == 'GOLD' || symbol == 'SILVER') &&
              materialPrice != null) ...[
            const SizedBox(height: 32),
            _buildSectionTitle(
              S.of(context).asset_details_local_prices,
              context,
            ),
            const SizedBox(height: 16),
            Container(
              // padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? context.surface.withOpacity(0.5)
                    : context.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.onSurface.withOpacity(0.1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    color: context.onSurface.withOpacity(0.03),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            S
                                .of(context)
                                .asset_details_key_stats, // Or a specific "Type" localization if available
                            style: context.textStyles.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            S.of(context).order_buy,
                            textAlign: TextAlign.right,
                            style: context.textStyles.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            S.of(context).order_sell,
                            textAlign: TextAlign.right,
                            style: context.textStyles.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: context.onSurface.withOpacity(0.05),
                    height: 1,
                  ),

                  // Table Rows
                  if (symbol == 'GOLD') ...[
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_24k,
                      materialPrice.p24Buy,
                      materialPrice.p24Sell,
                      context,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_21k,
                      materialPrice.p21Buy,
                      materialPrice.p21Sell,
                      context,
                      isAltRow: true,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_18k,
                      materialPrice.p18Buy,
                      materialPrice.p18Sell,
                      context,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_ounce,
                      materialPrice.ounceBuy,
                      materialPrice.ounceSell,
                      context,
                      isAltRow: true,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_pound,
                      materialPrice.goldPoundBuy,
                      materialPrice.goldPoundSell,
                      context,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_bar_50g,
                      materialPrice.bar50gBuy,
                      materialPrice.bar50gSell,
                      context,
                      isAltRow: true,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_bar_100g,
                      materialPrice.bar100gBuy,
                      materialPrice.bar100gSell,
                      context,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_gold_bar_250g,
                      materialPrice.bar250gBuy,
                      materialPrice.bar250gSell,
                      context,
                      isAltRow: true,
                      isLast: true,
                    ),
                  ] else if (symbol == 'SILVER') ...[
                    _buildPriceTableRow(
                      S.of(context).asset_details_silver_999,
                      materialPrice.silver999Buy,
                      materialPrice.silver999Sell,
                      context,
                    ),
                    _buildPriceTableRow(
                      S.of(context).asset_details_silver_925,
                      materialPrice.silver925Buy,
                      materialPrice.silver925Sell,
                      context,
                      isAltRow: true,
                      isLast: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (!isIndex) ...[
            _buildSectionTitle(
              S.of(context).asset_details_company_profile,
              context,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? context.surface.withOpacity(0.5)
                    : context.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.onSurface.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    S.of(context).asset_details_arabic_name,
                    stockData['company_name_ar'] ?? "-",
                    Icons.translate,
                    context,
                  ),
                  Divider(
                    color: context.onSurface.withOpacity(0.1),
                    height: 32,
                  ),
                  _buildDetailRow(
                    S.of(context).asset_details_isin_code,
                    stockData['isin_code'] ?? "-",
                    Icons.qr_code,
                    context,
                  ),
                  Divider(
                    color: context.onSurface.withOpacity(0.1),
                    height: 32,
                  ),
                  _buildDetailRow(
                    S.of(context).asset_details_listing_date,
                    stockData['listing_date'] != null
                        ? DateFormat(
                            'MMM d, yyyy',
                          ).format(DateTime.parse(stockData['listing_date']))
                        : "-",
                    Icons.calendar_today,
                    context,
                  ),
                  Divider(
                    color: context.onSurface.withOpacity(0.1),
                    height: 32,
                  ),
                  _buildDetailRow(
                    S.of(context).asset_details_website,
                    stockData['website'] ?? "-",
                    Icons.language,
                    context,
                    isLink: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          _buildSectionTitle(S.of(context).asset_details_about, context),
          const SizedBox(height: 12),
          Text(
            localizedDescription,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.onSurface.withOpacity(0.7),
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
          if (isIndex && constituents.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(
              S.of(context).asset_details_constituents,
              context,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: constituents.map((stock) {
                return Chip(
                  label: Text(
                    stock,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: context.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: context.surface,
                  side: BorderSide(color: context.onSurface.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 40),
        ],
      );
    },
  );
}

Widget _buildSectionTitle(String title, BuildContext context) {
  return Text(
    title,
    style: context.textStyles.headlineMedium?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
  );
}

Widget _buildSubsectionTitle(String title, BuildContext context) {
  return Text(
    title,
    style: context.textStyles.titleMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: context.onSurface.withOpacity(0.7),
    ),
  );
}

Widget _buildStatCard(
  String label,
  String value,
  IconData icon,
  BuildContext context, {
  Color? valueColor,
}) {
  final isDarkMode = context.isDarkMode;

  // شيلنا الـ cardWidth اليدوي عشان الـ Grid يتحكم في المساحة صح
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDarkMode ? context.surface.withOpacity(0.5) : context.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: context.onSurface.withOpacity(0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (valueColor ?? context.primary).withOpacity(0.1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: valueColor ?? context.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          value,
          maxLines: 1, // ميزيدش عن سطر واحد عشان ميبوظش الـ Grid
          style: context.textStyles.headlineMedium?.copyWith(
            color: valueColor ?? context.onSurface,
            fontSize: 18,
            letterSpacing: -0.5,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(
  String label,
  String value,
  IconData icon,
  BuildContext context, {
  bool isLink = false,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: context.primary, size: 20),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: isLink && value != "-"
                  ? () async {
                      final uri = Uri.parse(value);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  : null,
              child: Text(
                value,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: isLink && value != "-"
                      ? context.primary
                      : context.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Helper function to determine RSI color based on value

Widget _buildPriceTableRow(
  String title,
  double buyPrice,
  double sellPrice,
  BuildContext context, {
  bool isAltRow = false,
  bool isLast = false,
}) {
  return Column(
    children: [
      Container(
        color: isAltRow
            ? context.onSurface.withOpacity(0.01)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Title
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Buy Price (Greenish)
            Expanded(
              flex: 3,
              child: Text(
                PriceFormatter.formatPrice(buyPrice),
                textAlign: TextAlign.right,
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                  fontFamily: 'monospace',
                  fontSize: 14.5,
                ),
              ),
            ),

            // Sell Price (Reddish)
            Expanded(
              flex: 3,
              child: Text(
                PriceFormatter.formatPrice(sellPrice),
                textAlign: TextAlign.right,
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[500],
                  fontFamily: 'monospace',
                  fontSize: 14.5,
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Divider(color: context.onSurface.withOpacity(0.05), height: 1),
    ],
  );
}
