import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:egx/features/simulation/presentation/widgets/holding_list_item.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/simulation/presentation/widgets/portfolio_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:egx/features/simulation/presentation/widgets/transaction_history_list.dart';

class PortfolioPage extends GetView<SimulationController> {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: context.background,
          elevation: 0,
          leadingWidth: ResponsiveLayout.isDesktop(context) ? 0 : 80,
          leading: ResponsiveLayout.isDesktop(context)
              ? null
              : Center(
                  child: Container(
                    margin: const EdgeInsets.only(left: 0.0),
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.primary.withOpacity(0.2),
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
          title: Text(
            context.s.sim_portfolio_title,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: ResponsiveLayout.isDesktop(context)
              ? []
              : [
                  IconButton(
                    icon: Icon(Icons.history, color: context.onSurface),
                    onPressed: () =>
                        Get.toNamed(AppPages.transactionHistoryPage),
                    tooltip: context.s.sim_transaction_history,
                  ),
                ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.wallet.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: context.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: context.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.s.button_retry),
                ),
              ],
            ),
          );
        }

        final portfolioContent = RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // Portfolio Stats Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PortfolioStatsCard(controller: controller),
                ),
              ),

              // Holdings Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.s.sim_holdings_count(controller.positionsCount),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (controller.positionsCount > 0)
                        TextButton.icon(
                          onPressed: () {
                            // Could add a "View All" page if needed
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: context.primary,
                          ),
                          label: Text(
                            context.s.sim_view_all,
                            style: TextStyle(color: context.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Holdings List
              if (controller.holdings.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 80,
                          color: context.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.s.sim_no_holdings,
                          style: TextStyle(
                            fontSize: 18,
                            color: context.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.s.sim_start_trading,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.trending_up),
                          label: Text(context.s.sim_go_to_markets),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final holding = controller.holdings[index];
                      return HoldingListItem(
                        holding: holding,
                        controller: controller,
                      );
                    }, childCount: controller.holdings.length),
                  ),
                ),
            ],
          ),
        );

        if (ResponsiveLayout.isDesktop(context)) {
          return Row(
            children: [
              Expanded(flex: 3, child: portfolioContent),
              VerticalDivider(
                width: 1,
                color: context.onSurface.withOpacity(0.1),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: context.surface.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          context.s.sim_transaction_history,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: TransactionHistoryList()),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return portfolioContent;
      }),
    );
  }
}
