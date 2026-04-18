import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';

import 'package:egx/features/home/presentation/widgets/shared/logo_animation.dart';
import 'package:egx/features/home/presentation/widgets/shared/market_header.dart';
import 'package:egx/features/home/presentation/widgets/shared/trending_stock_card.dart';
import 'package:egx/features/home/presentation/widgets/shared/market_overview_section.dart';
import 'package:egx/features/home/presentation/widgets/shared/quick_indicators_section.dart';

import 'package:egx/features/home/presentation/widgets/shared/watchlist_section.dart';
import 'package:egx/features/home/presentation/widgets/desktop/latest_news_section.dart';
import 'package:egx/features/home/presentation/widgets/desktop/home_shimmer_loading_desktop.dart';
import 'package:egx/features/home/presentation/widgets/desktop/notification_dropdown.dart';
import 'package:egx/features/notifications/presentation/controller/notification_controller.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Desktop Home Page - 2 column layout using original mobile widgets
class HomePageDesktop extends GetView<HomeController> {
  const HomePageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const HomeShimmerLoadingDesktop();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState(context);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel (65%)
              Expanded(flex: 65, child: _buildLeftPanel(context)),

              // Divider
              VerticalDivider(
                width: 1,
                color: context.onSurface.withOpacity(0.1),
              ),

              // Right Panel (35%)
              Expanded(flex: 35, child: _buildRightPanel(context)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: context.primary,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Hello user + Logo + Notifications)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeader(context),
            ),

            // Quick Indicators (original mobile widget)
            const QuickIndicatorsSection(),

            // Watchlist (original mobile widget)
            Obx(
              () => WatchlistSection(
                watchlist: controller.watchlist.toList(),
                limit: 5,
                onSeeAll: () => Get.toNamed(AppPages.watchlistPage),
              ),
            ),

            // Trending Stocks header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: GestureDetector(
                onTap: () => Get.toNamed(AppPages.trendingStocksPage),
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

            // Trending stocks (2-row horizontal grid for desktop)
            SizedBox(
              height: 380, // Height for 2 rows
              child: Obx(
                () => GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 rows
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.55, // Make cards taller/bigger
                  ),
                  itemCount: controller.trendingStocks.length,
                  itemBuilder: (context, index) {
                    final stock = controller.trendingStocks[index];
                    final usdRate = controller.currencyPrices['USDEGP'];
                    return TrendingStockCard(stock: stock, usdRate: usdRate);
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Intelligence Card
          Obx(
            () => MarketIntelligenceCard(
              marketHistory: controller.marketHistory.value,
            ),
          ),
          const SizedBox(height: 24),

          // Market Overview (Indices)
          Obx(
            () => MarketOverviewSection(
              indices: controller.marketIndices.toList(),
              trendingStocks: controller.trendingStocks.toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Latest News
          const LatestNewsSection(limit: 4),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Greeting + Logo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello user (like mobile)
            if (Get.isRegistered<SettingsController>())
              Obx(() {
                final name =
                    Get.find<SettingsController>().currentUser.value?.name ??
                    '';
                if (name.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    context.s.home_greeting(name),
                    style: TextStyle(
                      color: context.onSurface.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            // Animated Logo
            const EGXLogoStackLoop(),
          ],
        ),
        const Spacer(),

        // Refresh
        IconButton(
          onPressed: () => controller.refreshData(),
          icon: Obx(
            () => controller.isRefreshing.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.primary,
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    color: context.onSurface.withOpacity(0.6),
                  ),
          ),
          tooltip: context
              .s
              .retry_btn, // Using retry_btn as a proxy for refresh for now or I'll add refresh_label
        ),

        // Notifications
        IconButton(
          onPressed: () => Get.toNamed(AppPages.chatbotPage),
          icon: Icon(
            Icons.smart_toy_rounded,
            color: context.onSurface.withOpacity(0.6),
          ),
          tooltip: 'EGX AI',
        ),
        
        NotificationDropdown(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: context.onSurface.withOpacity(0.8),
                  size: 20,
                ),
              ),
              if (Get.isRegistered<NotificationController>())
                Obx(() {
                  final count = Get.find<NotificationController>().unreadCount;
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
