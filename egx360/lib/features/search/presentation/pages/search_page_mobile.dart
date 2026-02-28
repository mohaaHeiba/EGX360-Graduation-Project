import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/search/presentation/controllers/search_stocks_controller.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/build_list_item.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/build_news_item.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/build_stock_list_sliver.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/sliver_appbar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPageMobile extends GetView<SearchStocksController> {
  const SearchPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      context.s.search_cat_all,
      context.s.search_cat_stocks,
      context.s.search_cat_indices,
      context.s.search_cat_crypto,
      context.s.search_cat_materials,
    ];

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Obx(() {
          final bool isSearching = controller.searchController.text.isNotEmpty;
          final currentList = isSearching
              ? controller.searchResults
              : controller.initialPicks;
          final newsList = controller.latestNews;

          return CustomScrollView(
            controller: controller.searchPageScrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: context.background,
                floating: true,
                pinned: false,
                snap: true,
                elevation: 0,
                collapsedHeight: 65,
                expandedHeight: 65,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Column(
                    children: [
                      const SizedBox(height: 8),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isSearching
                                      ? GestureDetector(
                                          key: const ValueKey('clearBtn'),
                                          onTap: () {
                                            controller.searchController.clear();
                                            controller.onSearchChanged('');
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.cancel,
                                              size: 18,
                                              color: context.onSurface,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          key: ValueKey('empty'),
                                          width: 0,
                                        ),
                                ),
                                Container(
                                  height: 20,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  color: context.colors.outline.withOpacity(
                                    0.2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: controller.listen,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(
                                      right: 8,
                                      left: 4,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: controller.isListening.value
                                          ? context.primary.withOpacity(0.2)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      controller.isListening.value
                                          ? Icons.mic_rounded
                                          : Icons.mic_none_rounded,
                                      color: controller.isListening.value
                                          ? context.primary
                                          : context.onSurface,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  minHeight: 65,
                  maxHeight: 65,
                  child: Container(
                    color: context.background,
                    padding: const EdgeInsets.only(bottom: 12, top: 12),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedCategory.value == cat;
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
                                          color: context.primary.withOpacity(
                                            0.3,
                                          ),
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
                                    color: isSelected
                                        ? context.onPrimary
                                        : context.onSurface,
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
                  ),
                ),
              ),

              // --- 2.loading ---
              if (controller.isLoading.value)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: context.primary),
                  ),
                )
              // --- 3. result ---
              else if (isSearching)
                buildStockListSliver(context, currentList)
              else
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        context.s.search_market_movers,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Stock List
                    ...currentList.map(
                      (stock) => buildListItem(context, stock),
                    ),

                    // Loading indicator for stocks pagination
                    if (controller.selectedCategory.value == 'Stocks' &&
                        controller.isLoadingMoreStocks.value)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.primary,
                          ),
                        ),
                      ),

                    // News (Hide if category is Stocks)
                    if (controller.selectedCategory.value != 'Stocks') ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.newspaper_rounded,
                              size: 20,
                              color: context.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.s.search_latest_news,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppPages.allNewsPage);
                              },
                              child: Text(
                                context.s.search_view_all,
                                style: TextStyle(
                                  color: context.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // News List
                      if (newsList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              context.s.search_no_news,
                              style: TextStyle(
                                color: context.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                        )
                      else
                        ...newsList.map((news) => buildNewsItem(context, news)),
                    ],

                    const SizedBox(height: 40),
                  ]),
                ),
            ],
          );
        }),
      ),
    );
  }
}
