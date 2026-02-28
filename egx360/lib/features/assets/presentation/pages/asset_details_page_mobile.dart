import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';
import 'package:egx/features/assets/presentation/widgets/shared/chart_loading_shimmer.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_overview_tab.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_chart.dart';
import 'package:egx/features/assets/presentation/widgets/shared/build_community_tab.dart';
import 'package:egx/features/assets/presentation/widgets/mobile/build_news_tab_mobile.dart';
import 'package:egx/features/assets/presentation/widgets/mobile/build_price_header_mobile.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:egx/features/assets/presentation/widgets/shared/asset_details_tooltip.dart';
import 'package:egx/features/assets/presentation/widgets/shared/asset_time_range_selector.dart';
import 'package:egx/features/assets/presentation/widgets/shared/asset_live_chat_tab.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetDetailsPageMobile extends StatefulWidget {
  const AssetDetailsPageMobile({super.key});

  @override
  State<AssetDetailsPageMobile> createState() => _AssetDetailsPageMobileState();
}

class _AssetDetailsPageMobileState extends State<AssetDetailsPageMobile>
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
    final stockName = stockData['stock_name'] ?? stockData['symbol'] ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              toolbarHeight: 80,
              leadingWidth: 72,
              backgroundColor: Theme.of(context).colorScheme.background,
              pinned: true,
              floating: false,
              elevation: 0.0,
              flexibleSpace: null,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(stockData['logo_url'] ?? ''),
                    backgroundColor: Colors.grey[800],
                    child: stockData['logo_url'] == null
                        ? Text(
                            stockName.isNotEmpty ? stockName[0] : '?',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: context.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stockName,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isIndex
                            ? S.of(context).asset_details_index_label
                            : S.of(context).asset_details_stock_label,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.onSurface,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Obx(() {
                  final isMaterial =
                      controller.symbol == 'GOLD' ||
                      controller.symbol == 'SILVER';

                  if (isMaterial) {
                    return TextButton(
                      onPressed: () => controller.toggleCurrency(),
                      child: Text(
                        controller.isEgp.value ? "EGP" : "USD",
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return IconButton(
                    icon: Icon(
                      controller.isWatchlisted.value
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: controller.isWatchlisted.value
                          ? context.primary
                          : context.onSurface,
                    ),
                    onPressed: () => controller.toggleWatchlist(),
                  );
                }),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  Obx(() {
                    final candles = controller.candleData;
                    final currentPrice = candles.isNotEmpty
                        ? candles.last.close
                        : (stockData['current_price'] as num?)?.toDouble() ??
                              0.0;
                    double prevClose =
                        (stockData['prev_close'] as num?)?.toDouble() ?? 0.0;

                    if (controller.assetType.isCrypto &&
                        controller.prevClosePrice.value != 0) {
                      prevClose = controller.prevClosePrice.value;
                    }

                    final isMaterial =
                        controller.symbol == 'GOLD' ||
                        controller.symbol == 'SILVER';

                    return buildPriceHeaderMobile(
                      currentPrice,
                      prevClose,
                      controller.symbol,
                      context,
                      controller,
                      isCrypto: controller.assetType.isCrypto,
                      isIndex: isIndex,
                      isEgp: isMaterial ? controller.isEgp.value : true,
                      rate: isMaterial ? controller.usdToEgpRate : 1.0,
                    );
                  }),
                  const SizedBox(height: 20),

                  // Tooltip State
                  SizedBox(
                    height: 400,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Obx(() {
                          final initialPrevClose =
                              (stockData['prev_close'] as num?)?.toDouble() ??
                              0.0;

                          final displayData = controller.getChartDisplayData(
                            initialPrevClose,
                          );

                          return controller.isLoadingChart.value
                              ? const Center(child: AdvancedChartShimmer())
                              : Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: buildChart(
                                    context,
                                    displayData.candles,
                                    prevClose: displayData.prevClose,
                                    symbol: controller.symbol,
                                    timeRange:
                                        controller.selectedTimeRange.value,
                                    isCrypto: controller.assetType.isCrypto,
                                    onTrackballChange: (candle, xPos) {
                                      if (candle != null && xPos != null) {
                                        tooltipVisible.value = true;
                                        tooltipX.value = xPos;
                                        tooltipPrice.value = candle.close;
                                        final change =
                                            candle.close -
                                            displayData.prevClose;
                                        tooltipChange.value = change;
                                        tooltipPercentage.value =
                                            (change / displayData.prevClose) *
                                            100;
                                        tooltipDate.value = candle.candleTime;
                                      } else {
                                        tooltipVisible.value = false;
                                      }
                                    },
                                  ),
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
                            maxWidth: MediaQuery.of(context).size.width,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Time Range Selector
                  AssetTimeRangeSelector(controller: controller),
                ],
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                Container(
                  color: context.background,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: context.primary,
                    labelColor: context.primary,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(text: S.of(context).asset_details_tab_overview),
                      Tab(text: S.of(context).asset_details_tab_news),
                      Tab(text: S.of(context).asset_details_tab_community),
                      Tab(text: S.of(context).asset_details_tab_live_chat),
                    ],
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            Obx(() {
              final isMaterial =
                  controller.symbol == 'GOLD' || controller.symbol == 'SILVER';
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
            buildNewsTab(context, controller),
            buildCommunityTab(controller),
            AssetLiveChatTab(stockData: stockData),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 55;
  @override
  double get maxExtent => 55;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
