import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/currency/presentation/widgets/currency_chart_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:egx/features/currency/presentation/widgets/currency_chart.dart';

import 'package:egx/features/currency/presentation/widgets/currency_overview_tab.dart';
import 'package:egx/features/currency/presentation/widgets/build_currency_overview_tab.dart';
import 'package:egx/features/currency/presentation/widgets/currency_price_header.dart';
import 'package:egx/features/currency/data/datasources/currency_remote_datasource.dart';
import 'package:egx/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:egx/features/currency/domain/usecases/get_currency_history_usecase.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/features/currency/presentation/controllers/currency_details_controller.dart';

class CurrencyDetailsPage extends StatefulWidget {
  const CurrencyDetailsPage({super.key});

  @override
  State<CurrencyDetailsPage> createState() => _CurrencyDetailsPageState();
}

class _CurrencyDetailsPageState extends State<CurrencyDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> stockData = Get.arguments ?? {};

  late final dynamic controller;
  bool isCurrency = false;

  @override
  void initState() {
    super.initState();

    // Adjust tab length: 2 for Currency (Overview + Calculator)
    _tabController = TabController(length: 2, vsync: this);

    // Dependency Injection
    final remoteDataSource = CurrencyRemoteDataSourceImpl(
      client: http.Client(),
    );
    final repository = CurrencyRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final getCurrencyHistoryUseCase = GetCurrencyHistoryUseCase(repository);

    // Controller is already put by CurrencyBindings
    controller = Get.find<CurrencyDetailsController>();
    // If we need to update the symbol because Bindings might have run with old args (unlikely if new route)
    // But Bindings run on route access.
    // Let's just find it.
    if (controller.symbol.value != stockData['symbol']) {
      controller.changeCurrency(stockData['symbol'] ?? 'USDEGP');
    }
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
              title: _buildCurrencyTitle(
                context,
                controller as CurrencyDetailsController,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Obx(() {
                      final candles =
                          controller.candleData as List<CandleEntity>;
                      final currentPrice = candles.isNotEmpty
                          ? candles.last.close
                          : (stockData['current_price'] as num?)?.toDouble() ??
                                0.0;
                      final prevClose = controller.prevClosePrice.value;

                      return buildCurrencyPriceHeader(
                        currentPrice,
                        prevClose,
                        context,
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
                            double prevClose = controller.prevClosePrice.value;

                            // Fallback if prevClose is 0 and we have data
                            if (prevClose == 0 &&
                                controller.candleData.isNotEmpty) {
                              prevClose = controller.candleData.first.open;
                            }

                            return controller.isLoadingChart.value
                                ? const Center(child: AdvancedChartShimmer())
                                : Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: buildChart(
                                      // Calculate isPositive dynamically for the chart color
                                      controller.isPositivePerformance.value,
                                      context,
                                      controller.candleData
                                          as List<CandleEntity>,
                                      prevClose: prevClose,
                                      symbol: controller.symbol.value,
                                      timeRange:
                                          controller.selectedTimeRange.value,
                                      onTrackballChange: (candle, xPos) {
                                        if (candle != null && xPos != null) {
                                          tooltipVisible.value = true;
                                          tooltipX.value = xPos;
                                          tooltipPrice.value = candle.close;
                                          final change =
                                              candle.close - prevClose;
                                          tooltipChange.value = change;
                                          tooltipPercentage.value =
                                              (change / prevClose) * 100;
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
                            if (!tooltipVisible.value)
                              return const SizedBox.shrink();

                            final change = tooltipChange.value;
                            final percentage = tooltipPercentage.value;
                            final isPositiveChange = change >= 0;
                            final color = isPositiveChange
                                ? Colors.green
                                : Colors.red;
                            final sign = isPositiveChange ? '+' : '';

                            // Calculate left position to keep tooltip within bounds
                            // Assuming chart width is screen width - padding
                            // We center the tooltip on xPos
                            double left =
                                tooltipX.value - 75; // Half width approx
                            if (left < 0) left = 0;
                            // Max width check (simplified)
                            if (left >
                                MediaQuery.of(context).size.width - 160) {
                              left = MediaQuery.of(context).size.width - 160;
                            }

                            return Positioned(
                              top: 0,
                              left: left,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Price and Change Row
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          tooltipPrice.value.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$sign${change.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$sign${percentage.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Date
                                    Text(
                                      DateFormat(
                                        'MMM dd, HH:mm',
                                      ).format(tooltipDate.value),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Time Range Selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: (controller.timeRanges as List<String>).map((
                          range,
                        ) {
                          return Obx(() {
                            final isSelected =
                                controller.selectedTimeRange.value == range;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ChoiceChip(
                                label: Text(range),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    controller.updateTimeRange(range);
                                  }
                                },
                                selectedColor: context.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? context.onPrimary
                                      : context.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                backgroundColor: context.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3.(Sticky Header)
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
                      const Tab(text: "Overview"),
                      const Tab(text: "Calculator"),
                    ],
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        // محتوى التابات
        body: TabBarView(
          controller: _tabController,
          children: [
            Obx(
              () => buildCurrencyStatsTab(
                stockData,
                controller.candleData as List<CandleEntity>,
                symbol: controller.symbol.value,
                livePrevClose: controller.prevClosePrice.value,
                rate: 1.0,
              ),
            ),
            buildCurrencyCalculatorTab(controller as CurrencyDetailsController),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildCurrencyTitle(
    BuildContext context,
    CurrencyDetailsController controller,
  ) {
    return Obx(() {
      return PopupMenuButton<String>(
        onSelected: (String value) {
          controller.changeCurrency(value);
        },
        itemBuilder: (BuildContext context) {
          return controller.supportedCurrencies.entries.map((entry) {
            return PopupMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList();
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.transparent,
              child: Text(
                controller.currencyFlag,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      controller.currencyName,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: context.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  "Currency • EGP",
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.onSurface,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// --- Fix 3: تصحيح الكلاس المساعد ---
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  // جعلنا الارتفاع 55 لتجنب Overflow إذا كان الخط عريضاً
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

  // إضافة كلمة covariant هي الحل الأصح لتجنب أخطاء Dart الحديثة
  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
