import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/markets/presentation/widgets/desktop/stock_details_panel.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketsRightSidebar extends StatefulWidget {
  const MarketsRightSidebar({super.key});

  @override
  State<MarketsRightSidebar> createState() => _MarketsRightSidebarState();
}

class _MarketsRightSidebarState extends State<MarketsRightSidebar> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketsController>();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // Top Row: Title + Toggle + Search
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showDetails
                          ? context.s.sidebar_details
                          : context.s.sidebar_watchlist,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Toggle Button
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showDetails = !_showDetails;
                            });
                          },
                          icon: Icon(
                            _showDetails ? Icons.list : Icons.info_outline,
                            size: 20,
                          ),
                          tooltip: _showDetails
                              ? context.s.sidebar_show_watchlist
                              : context.s.sidebar_show_details,
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (!_showDetails) ...[
                          const SizedBox(width: 12),
                          // Search Button (only for watchlist)
                          Obx(
                            () => IconButton(
                              onPressed: controller.toggleSearch,
                              icon: Icon(
                                controller.isSearching.value
                                    ? Icons.close
                                    : Icons.search,
                                size: 20,
                              ),
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                // Search Bar (only when in watchlist mode)
                if (!_showDetails)
                  Obx(() {
                    if (controller.isSearching.value) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged,
                          decoration: InputDecoration(
                            hintText: context.s.sidebar_search_symbol,
                            prefixIcon: const Icon(Icons.search, size: 18),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(
                              context,
                            ).cardColor.withOpacity(0.5),
                            filled: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                if (!_showDetails) ...[
                  const SizedBox(height: 8),
                  // Column Headers (only for watchlist)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          context.s.sidebar_symbol,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          context.s.sidebar_last,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          context.s.sidebar_chg,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          context.s.sidebar_chg_percent,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Content: Toggle between Watchlist and Details
          Expanded(
            child: _showDetails
                ? const StockDetailsPanel()
                : _buildWatchlist(controller, context),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlist(MarketsController controller, BuildContext context) {
    return Obx(() {
      List<StockEntity> displayList = controller.isSearching.value
          ? controller.searchResults
          : controller.popularAssets;

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (displayList.isEmpty) {
        return Center(
          child: Text(
            controller.isSearching.value
                ? context.s.sidebar_no_results
                : context.s.sidebar_no_assets,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        );
      }

      return ListView.separated(
        itemCount: displayList.length,
        separatorBuilder: (c, i) => Divider(
          height: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
        itemBuilder: (context, index) {
          final stock = displayList[index];
          final isSelected =
              controller.selectedStock.value?.symbol == stock.symbol;

          // Data Logic
          final double price = stock.currentPrice ?? stock.prevClose ?? 0.0;
          final double prev = stock.prevClose ?? 0.0;
          final double change = prev != 0 ? price - prev : 0.0;
          final double changePercent = prev != 0 ? (change / prev) * 100 : 0.0;

          final isPositive = change >= 0;
          final color = change == 0
              ? Theme.of(context).textTheme.bodyMedium?.color
              : (isPositive ? AppColors.candleGreen : AppColors.candleRed);

          return InkWell(
            onTap: () => controller.selectStock(stock),
            child: Container(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Symbol & Name
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        if (stock.logoUrl != null && stock.logoUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              stock.logoUrl!,
                              width: 16,
                              height: 16,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                stock.sector ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Last
                  Expanded(
                    flex: 2,
                    child: Text(
                      price > 0 ? price.toStringAsFixed(2) : '-',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Change
                  Expanded(
                    flex: 2,
                    child: Text(
                      change != 0 ? change.toStringAsFixed(2) : '-',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),

                  // Change %
                  Expanded(
                    flex: 2,
                    child: Text(
                      changePercent != 0
                          ? '${changePercent.toStringAsFixed(2)}%'
                          : '-',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
