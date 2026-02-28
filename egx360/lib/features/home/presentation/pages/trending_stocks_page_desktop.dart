import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:egx/features/home/presentation/widgets/shared/trending_stock_card.dart';
import 'package:egx/features/home/presentation/widgets/shared/trending_stocks_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrendingStocksPageDesktop extends StatefulWidget {
  const TrendingStocksPageDesktop({super.key});

  @override
  State<TrendingStocksPageDesktop> createState() =>
      _TrendingStocksPageDesktopState();
}

class _TrendingStocksPageDesktopState extends State<TrendingStocksPageDesktop> {
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Fetch full list of trending stocks when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFullTrendingStocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: context.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primary.withOpacity(0.2),
                          context.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: context.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trending Stocks',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(() {
                        final count = controller.trendingStocks.length;
                        return Text(
                          '$count stocks currently trending',
                          style: TextStyle(
                            color: context.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(color: context.onSurface.withOpacity(0.1), height: 1),

            // Grid Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const TrendingStocksShimmer();
                }

                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 rows
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.55, // Make cards taller/bigger
                  ),
                  itemCount: controller.trendingStocks.length,
                  itemBuilder: (context, index) {
                    final stock = controller.trendingStocks[index];
                    final usdRate = controller.currencyPrices['USDEGP'];
                    return TrendingStockCard(stock: stock, usdRate: usdRate);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
