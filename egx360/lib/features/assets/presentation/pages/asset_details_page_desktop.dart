import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';
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
    _tabController = TabController(length: 4, vsync: this);
    controller = Get.find<AssetDetailsController>();
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

          // Right Panel - Full Height Tabs Section (40%)
          Expanded(flex: 40, child: _buildTabsSection(context, isIndex)),
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
                          showRightTitles:
                              true, // Enable right axis digits on desktop
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
                  technicalResult: controller.technicalResult.value,
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
