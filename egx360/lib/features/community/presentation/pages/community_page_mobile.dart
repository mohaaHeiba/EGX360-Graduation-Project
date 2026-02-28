import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:egx/features/community/presentation/widgets/posts_list_widget.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/sliver_appbar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityPageMobile extends GetView<CommunityController> {
  const CommunityPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshPosts,
          color: context.primary,
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              // --- 1. العنوان (بيختفي تماماً) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    17,
                    21,
                    4,
                  ), // المحافظة على مسافاتك
                  child: Obx(() {
                    final selected = controller.selectedStock.value;
                    return Row(
                      children: [
                        if (selected?.logoUrl != null)
                          Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: selected!.logoUrl!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        Text(
                          selected == null
                              ? context.s.community_title
                              : selected.symbol,
                          style: TextStyle(
                            color: context.onSurface,
                            fontSize: 31, // الحجم اللي اخترته
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // --- 2. الفلاتر (بتثبت فوق) ---
              // --- 2. الفلاتر (بتثبت فوق) ---
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  minHeight: 65,
                  maxHeight: 65,
                  child: Container(
                    color: context.background,
                    alignment: Alignment.center,
                    // شلنا الـ Obx من هنا ونقلناها لكل عنصر داخلي
                    child: Obx(() {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.stocks.length + 1,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return Obx(() {
                            if (index == 0) {
                              final isSelected =
                                  controller.selectedStock.value == null;
                              return _buildFilterChip(
                                context: context,
                                label: context.s.community_all,
                                isSelected: isSelected,
                                onTap: () => controller.setAllFilter(),
                              );
                            }

                            final stock = controller.stocks[index - 1];
                            final isSelected =
                                controller.selectedStock.value?.symbol ==
                                stock.symbol;
                            return _buildFilterChip(
                              context: context,
                              label: stock.symbol,
                              isSelected: isSelected,
                              logoUrl: stock.logoUrl,
                              onTap: () => controller.toggleStockFilter(stock),
                            );
                          });
                        },
                      );
                    }),
                  ),
                ),
              ), // --- 3. قائمة المنشورات ---
              PostsListWidget(controller: controller),

              // Loading الـ Pagination
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isPaginationLoading.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.primary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? logoUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primary
              : context.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.primary
                : context.colors.outline.withOpacity(0.08),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logoUrl != null) ...[
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? context.onPrimary : context.onSurface,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
