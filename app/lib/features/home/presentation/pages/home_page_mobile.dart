import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:egx/features/home/presentation/widgets/mobile/home_app_bar_delegate.dart';
import 'package:egx/features/home/presentation/widgets/shared/market_header.dart';
import 'package:egx/features/home/presentation/widgets/shared/trending_stock_card.dart';
import 'package:egx/features/home/presentation/widgets/shared/market_overview_section.dart';
import 'package:egx/features/home/presentation/widgets/shared/quick_indicators_section.dart';
import 'package:egx/features/home/presentation/widgets/mobile/home_shimmer_loading_mobile.dart';
import 'package:egx/features/home/presentation/widgets/shared/watchlist_section.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePageMobile extends GetView<HomeController> {
  const HomePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: context.primary,
          backgroundColor: context.surface,
          child: CustomScrollView(
            slivers: [
              // Dynamic App Bar - Always visible
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeIdentityHeader(),
              ),

              // Content controlled by state
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const HomeShimmerLoadingMobile();
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: context.textStyles.bodyLarge?.copyWith(
                                color: context.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: controller.fetchHomeData,
                              icon: const Icon(Icons.refresh),
                              label: Text(context.s.retry_btn),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primary,
                                foregroundColor: context.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Success Content
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (Market Status)
                      Obx(() {
                        return MarketIntelligenceCard(
                          marketHistory: controller.marketHistory.value,
                        );
                      }),

                      // QuickIndicatorsSection
                      const QuickIndicatorsSection(),

                      // Watchlist Section
                      Obx(() {
                        return WatchlistSection(
                          watchlist: controller.watchlist.toList(),
                          limit: 5,
                          onSeeAll: () {
                            Get.toNamed(AppPages.watchlistPage);
                          },
                        );
                      }),

                      // Trending Stocks Section Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppPages.trendingStocksPage);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: context.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.s.trending_stocks_title,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: context.onSurface.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Horizontal Scrollable Stock Cards
                      SizedBox(
                        height: 150,
                        child: Obx(() {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: controller.trendingStocks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final stock = controller.trendingStocks[index];
                              final usdRate =
                                  controller.currencyPrices['USDEGP'];
                              return TrendingStockCard(
                                stock: stock,
                                usdRate: usdRate,
                              );
                            },
                          );
                        }),
                      ),

                      // Market Overview
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Obx(() {
                          return MarketOverviewSection(
                            indices: controller.marketIndices.toList(),
                            trendingStocks: controller.trendingStocks.toList(),
                          );
                        }),
                      ),

                      // Bottom Padding
                      const SizedBox(height: 40),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
