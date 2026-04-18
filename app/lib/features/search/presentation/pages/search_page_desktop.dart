import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/search/presentation/controllers/search_stocks_controller.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/build_news_item.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/search_stock_card_desktop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPageDesktop extends GetView<SearchStocksController> {
  const SearchPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel (70%) - Market Movers Grid
          Expanded(flex: 70, child: _buildLeftPanel(context)),

          // Divider
          VerticalDivider(width: 1, color: context.onSurface.withOpacity(0.1)),

          // Right Panel (30%) - Latest News Sidebar
          Expanded(flex: 30, child: _buildRightPanel(context)),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header / Search Bar Area
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.s.search_market_overview,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: context.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.colors.outline.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search_rounded,
                      color: context.onSurface,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 15,
                          height: 1.2,
                        ),
                        cursorColor: context.primary,
                        decoration: InputDecoration(
                          fillColor: context.surface.withOpacity(0.01),
                          filled: true,
                          hintText: context.s.search_hint_main,
                          hintStyle: TextStyle(
                            color: context.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    // Buttons (X + Mic)
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     AnimatedSwitcher(
                    //       duration: const Duration(milliseconds: 200),
                    //       child: isSearching
                    //           ? GestureDetector(
                    //               key: const ValueKey('clearBtn'),
                    //               onTap: () {
                    //                 controller.searchController.clear();
                    //                 controller.onSearchChanged('');
                    //               },
                    //               child: Padding(
                    //                 padding: const EdgeInsets.all(8.0),
                    //                 child: Icon(
                    //                   Icons.cancel,
                    //                   size: 18,
                    //                   color: context.onSurface,
                    //                 ),
                    //               ),
                    //             )
                    //           : const SizedBox(
                    //               key: ValueKey('empty'),
                    //               width: 0,
                    //             ),
                    //     ),
                    //     Container(
                    //       height: 20,
                    //       width: 1,
                    //       margin: const EdgeInsets.symmetric(horizontal: 4),
                    //       color: context.colors.outline.withOpacity(0.2),
                    //     ),
                    //     GestureDetector(
                    //       onTap: controller.listen,
                    //       child: AnimatedContainer(
                    //         duration: const Duration(milliseconds: 300),
                    //         margin: const EdgeInsets.only(right: 8, left: 4),
                    //         padding: const EdgeInsets.all(8),
                    //         decoration: BoxDecoration(
                    //           color: controller.isListening.value
                    //               ? context.primary.withOpacity(0.2)
                    //               : Colors.transparent,
                    //           shape: BoxShape.circle,
                    //         ),
                    //         child: Icon(
                    //           controller.isListening.value
                    //               ? Icons.mic_rounded
                    //               : Icons.mic_none_rounded,
                    //           color: controller.isListening.value
                    //               ? context.primary
                    //               : context.onSurface,
                    //           size: 22,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Categories
        _buildCategories(context),

        // Grid Content
        Expanded(
          child: Obx(() {
            final isSearching = controller.searchController.text.isNotEmpty;
            final currentList = isSearching
                ? controller.searchResults
                : controller.initialPicks;

            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (currentList.isEmpty) {
              return Center(
                child: Text(
                  context.s.search_results_not_found,
                  style: TextStyle(color: context.onSurface.withOpacity(0.5)),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: currentList.length,
              itemBuilder: (context, index) {
                return SearchStockCardDesktop(stock: currentList[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface.withOpacity(
          0.2,
        ), // Subtle background for sidebar
        border: Border(
          left: BorderSide(color: context.colors.outline.withOpacity(0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.s.search_latest_news,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppPages.allNewsPage),
                  child: Text(context.s.search_view_all),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final newsList = controller.latestNews;
              if (newsList.isEmpty) {
                return Center(
                  child: Text(
                    context.s.search_no_news,
                    style: TextStyle(color: context.onSurface.withOpacity(0.5)),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemCount: newsList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return buildNewsItem(context, newsList[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      context.s.search_cat_all,
      context.s.search_cat_stocks,
      context.s.search_cat_indices,
      context.s.search_cat_crypto,
      context.s.search_cat_materials,
      'Currencies',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.primary
                      : context.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? context.primary
                        : context.colors.outline.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.primary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? context.onPrimary : context.onSurface,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
