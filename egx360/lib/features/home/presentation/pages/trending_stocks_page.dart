import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:egx/features/home/presentation/widgets/shared/trending_stock_card.dart';
import 'package:egx/features/home/presentation/widgets/shared/trending_stocks_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrendingStocksPage extends StatefulWidget {
  const TrendingStocksPage({super.key});

  @override
  State<TrendingStocksPage> createState() => _TrendingStocksPageState();
}

class _TrendingStocksPageState extends State<TrendingStocksPage> {
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
      appBar: customAppbar(() => Get.back(), 'Trending Stocks'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const TrendingStocksShimmer();
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.8, // Adjust based on card design
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
    );
  }
}
