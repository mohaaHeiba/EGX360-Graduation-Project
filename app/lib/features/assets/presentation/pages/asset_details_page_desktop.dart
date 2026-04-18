import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_currency_calculator_tab.dart';
import 'package:egx/features/assets/presentation/widgets/shared/chart_loading_shimmer.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_chart.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_community_tab.dart';
import 'package:egx/features/assets/presentation/widgets/desktop/build_news_tab_desktop.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_overview_tab.dart';
import 'package:egx/features/assets/presentation/widgets/desktop/build_price_header_desktop.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:egx/features/assets/presentation/widgets/shared/asset_details_tooltip.dart';
import 'package:egx/features/assets/presentation/widgets/shared/asset_time_range_selector.dart';
import 'package:egx/features/assets/presentation/widgets/shared/asset_live_chat_tab.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetDetailsPageDesktop extends StatefulWidget {
  const AssetDetailsPageDesktop({super.key});

  @override
  State<AssetDetailsPageDesktop> createState() =>
      _AssetDetailsPageDesktopState();
}

class _AssetDetailsPageDesktopState extends State<AssetDetailsPageDesktop>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, dynamic> stockData = Get.arguments ?? {};
  late final AssetDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssetDetailsController>();
    // Currency doesn't use tabs — only non-currency assets do
    _tabController = TabController(
      length: controller.assetType.isCurrency ? 1 : 4,
      vsync: this,
    );
  }

  // Tooltip State
  final tooltipVisible = false.obs;
  final tooltipX = 0.0.obs;
  final tooltipPrice = 0.0.obs;
  final tooltipChange = 0.0.obs;
  final tooltipPercentage = 0.0.obs;
  final tooltipDate = DateTime.now().obs;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIndex = stockData['sector'] == 'Indices';

    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Chart Section with App Bar (60%)
          Expanded(
            flex: 60,
            child: Column(
              children: [
                // Chart Content
                Expanded(child: _buildChartSection(context, isIndex)),
              ],
            ),
          ),

          // Vertical Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: context.onSurface.withOpacity(0.1),
          ),

          // Right Panel – currency gets OHLC + calculator; others get tabs
          Expanded(
            flex: 40,
            child: controller.assetType.isCurrency
                ? _buildCurrencyRightPanel(context)
                : _buildTabsSection(context, isIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, bool isIndex) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 4, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Header
          Obx(() {
            final candles = controller.candleData;
            final currentPrice = candles.isNotEmpty
                ? candles.last.close
                : (stockData['current_price'] as num?)?.toDouble() ?? 0.0;
            double prevClose =
                (stockData['prev_close'] as num?)?.toDouble() ?? 0.0;

            if (controller.assetType.isCrypto &&
                controller.prevClosePrice.value != 0) {
              prevClose = controller.prevClosePrice.value;
            }

            // For currency use live rate as "current price"
            if (controller.assetType.isCurrency) {
              return _buildCurrencyPriceHeader(context);
            }

            final isMaterial =
                controller.symbol == 'GOLD' || controller.symbol == 'SILVER';

            return buildPriceHeaderDesktop(
              currentPrice,
              prevClose,
              controller.symbol,
              context,
              controller,
              stockData,
              isCrypto: controller.assetType.isCrypto,
              isIndex: isIndex,
              isEgp: isMaterial ? controller.isEgp.value : true,
              rate: isMaterial ? controller.usdToEgpRate : 1.0,
            );
          }),

          const SizedBox(height: 24),

          // Chart with Tooltip
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  final initialPrevClose =
                      (stockData['prev_close'] as num?)?.toDouble() ?? 0.0;

                  final displayData = controller.getChartDisplayData(
                    initialPrevClose,
                  );

                  return controller.isLoadingChart.value
                      ? const Center(child: AdvancedChartShimmer())
                      : buildChart(
                          context,
                          displayData.candles,
                          prevClose: displayData.prevClose,
                          symbol: controller.symbol,
                          timeRange: controller.selectedTimeRange.value,
                          isCrypto: controller.assetType.isCrypto,
                          showRightTitles: true,
                          onTrackballChange: (candle, xPos) {
                            if (candle != null && xPos != null) {
                              tooltipVisible.value = true;
                              tooltipX.value = xPos;
                              tooltipPrice.value = candle.close;
                              final change =
                                  candle.close - displayData.prevClose;
                              tooltipChange.value = change;
                              tooltipPercentage.value =
                                  (change / displayData.prevClose) * 100;
                              tooltipDate.value = candle.candleTime;
                            } else {
                              tooltipVisible.value = false;
                            }
                          },
                        );
                }),

                // Tooltip Overlay
                Obx(() {
                  return AssetDetailsTooltip(
                    visible: tooltipVisible.value,
                    x: tooltipX.value,
                    price: tooltipPrice.value,
                    change: tooltipChange.value,
                    percentage: tooltipPercentage.value,
                    date: tooltipDate.value,
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Time Range Selector
          Center(child: AssetTimeRangeSelector(controller: controller)),
        ],
      ),
    );
  }

  // ── Currency-specific right panel ── OHLC stats on top, calculator below ──
  Widget _buildCurrencyRightPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ① OHLC Key Stats Card
          _buildCurrencyOhlcCard(context),

          const SizedBox(height: 24),

          // Divider
          Divider(color: context.onSurface.withOpacity(0.1)),

          const SizedBox(height: 16),

          // ② Currency Calculator
          Text(
            'Currency Converter',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          buildCurrencyCalculatorTab(controller),

          const SizedBox(height: 32),
          Divider(color: context.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),

          // ③ Currency News
          Text(
            S.of(context).asset_details_tab_news,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 600,
            child: buildNewsTabDesktop(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOhlcCard(BuildContext context) {
    return Obx(() {
      final candles = controller.candleData;

      if (candles.isEmpty) {
        return Container(
          height: 80,
          alignment: Alignment.center,
          child: Text(
            'Loading stats…',
            style: TextStyle(color: context.onSurface.withOpacity(0.5)),
          ),
        );
      }

      final last = candles.last;
      final highVal = candles
          .map((e) => e.high)
          .reduce((a, b) => a > b ? a : b);
      final lowVal = candles.map((e) => e.low).reduce((a, b) => a < b ? a : b);
      final prevClose = controller.prevClosePrice.value != 0
          ? controller.prevClosePrice.value
          : candles.first.open;

      String fmt(double v) =>
          v >= 10 ? v.toStringAsFixed(2) : v.toStringAsFixed(4);

      // Mirror of _buildStatCard in build_overview_tab.dart
      Widget card(String label, String value, IconData icon, {Color? color}) {
        final c = color ?? context.primary;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? context.surface.withOpacity(0.5)
                : context.surface,
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
                      color: c.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: c),
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
                maxLines: 1,
                style: context.textStyles.headlineMedium?.copyWith(
                  color: c,
                  fontSize: 16,
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }

      final cards = [
        card('Open', '${fmt(last.open)} EGP', Icons.login),
        card(
          'High',
          '${fmt(highVal)} EGP',
          Icons.arrow_upward,
          color: Colors.greenAccent,
        ),
        card(
          'Low',
          '${fmt(lowVal)} EGP',
          Icons.arrow_downward,
          color: Colors.redAccent,
        ),
        card('Close', '${fmt(last.close)} EGP', Icons.show_chart),
        card('Prev Close', '${fmt(prevClose)} EGP', Icons.history),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Data',
            style: context.textStyles.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: context.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisExtent: 100,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) => cards[i],
          ),
        ],
      );
    });
  }

  // ── Currency-specific price header (flag + name + live rate) ──
  Widget _buildCurrencyPriceHeader(BuildContext context) {
    return Obx(() {
      final rate = controller.currentRate.value;
      final sym = controller.currencySymbolObs.value;
      final foreignCode = sym.length >= 3 ? sym.substring(0, 3) : 'USD';
      final prevRate = controller.prevClosePrice.value;
      final change = prevRate != 0 ? rate - prevRate : 0.0;
      final changePct = prevRate != 0 ? (change / prevRate) * 100 : 0.0;
      final isPositive = change >= 0;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Flag
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 4),
            child: Text(
              controller.currencyFlag,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + symbol
                Text(
                  controller.currencyName,
                  style: context.textStyles.titleMedium?.copyWith(
                    color: context.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                // Rate
                Text(
                  rate > 0 ? '${rate.toStringAsFixed(2)} EGP' : '-- EGP',
                  style: context.textStyles.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.onSurface,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                // Change
                if (prevRate != 0)
                  Row(
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 16,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change.abs().toStringAsFixed(4)}  (${changePct.abs().toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '1 $foreignCode',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabsSection(BuildContext context, bool isIndex) {
    return Column(
      children: [
        // TabBar
        Container(
          decoration: BoxDecoration(
            color: context.surface.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: context.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: context.primary,
            labelColor: context.primary,
            unselectedLabelColor: context.onSurface.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: S.of(context).asset_details_tab_overview),
              Tab(text: S.of(context).asset_details_tab_news),
              Tab(text: S.of(context).asset_details_tab_community),
              Tab(text: S.of(context).asset_details_tab_live_chat),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              Obx(() {
                final isMaterial =
                    controller.symbol == 'GOLD' ||
                    controller.symbol == 'SILVER';
                return buildOverviewTab(
                  stockData,
                  controller.candleData,
                  symbol: controller.symbol,
                  materialPrice: controller.materialPrice.value,
                  livePrevClose: controller.assetType.isCrypto
                      ? controller.prevClosePrice.value
                      : null,
                  isIndex: isIndex,
                  isEgp: isMaterial ? controller.isEgp.value : true,
                  isCurrency: false,
                  rate: isMaterial ? controller.usdToEgpRate : 1.0,
                  aiPrediction: controller.aiPrediction.value,
                );
              }),

              // News Tab
              buildNewsTabDesktop(context, controller),

              // Community Tab
              buildCommunityTab(controller),

              // Live Chat Tab
              AssetLiveChatTab(stockData: stockData),
            ],
          ),
        ),
      ],
    );
  }
}
