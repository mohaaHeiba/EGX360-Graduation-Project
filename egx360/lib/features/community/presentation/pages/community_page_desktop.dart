import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:egx/features/community/presentation/widgets/posts_list_widget.dart';
import 'package:egx/features/post_details/presentation/widgets/desktop_post_details_wrapper.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityPageDesktop extends GetView<CommunityController> {
  const CommunityPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Left Sidebar (Profile + Categories) - Fixed
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: context.onSurface.withOpacity(0.05)),
                ),
              ),
              child: Column(
                children: [
                  _buildProfileSection(context),
                  Divider(color: context.onSurface.withOpacity(0.05)),
                  Expanded(child: _buildCategoriesList(context)),
                ],
              ),
            ),
          ),

          // 2. Center Feed (Scrollable)
          Expanded(flex: 6, child: _buildCenterPanel(context)),

          // 3. Right Sidebar (Trending) - Fixed
          Expanded(flex: 3, child: _buildRightPanel(context)),
        ],
      ),
    );
  }

  // ================== Left Panel (Profile & Navigation) ==================

  Widget _buildProfileSection(BuildContext context) {
    // Check if SettingsController is registered, if not, handle gracefully
    if (!Get.isRegistered<SettingsController>()) {
      return const SizedBox();
    }
    final SettingsController settingsController =
        Get.find<SettingsController>();

    return Obx(() {
      final user = settingsController.currentUser.value;
      if (user == null) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // Navigate to My Profile
                Get.toNamed(AppPages.profilePage, arguments: user);
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.avatarUrl ?? "",
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.person, color: context.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    user.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.email,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mini Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  context,
                  settingsController.userStats.value?.postsCount.toString() ??
                      "0",
                  context.s.community_posts,
                ),
                _buildMiniStat(
                  context,
                  settingsController.userStats.value?.followersCount
                          .toString() ??
                      "0",
                  context.s.community_followers,
                ),
                _buildMiniStat(
                  context,
                  settingsController.userStats.value?.followingCount
                          .toString() ??
                      "0",
                  context.s.community_following,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoriesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            context.s.community_communities,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.stocks.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildNavItem(
                    context,
                    title: context.s.community_all_feeds,
                    icon: Icons.dashboard_outlined,
                    isSelected: controller.selectedStock.value == null,
                    onTap: () => controller.setAllFilter(),
                  );
                }
                final stock = controller.stocks[index - 1];
                return _buildNavItem(
                  context,
                  title: stock.symbol,
                  imageUrl: stock.logoUrl,
                  isSelected:
                      controller.selectedStock.value?.symbol == stock.symbol,
                  onTap: () => controller.toggleStockFilter(stock),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    IconData? icon,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? context.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (imageUrl != null)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Icon(
                    icon ?? Icons.circle,
                    size: 22,
                    color: isSelected
                        ? context.primary
                        : context.onSurface.withOpacity(0.5),
                  ),

                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? context.primary
                          : context.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== Center Panel (The Feed) ==================

  Widget _buildCenterPanel(BuildContext context) {
    return Container(
      color: context.background, // Pure black/dark
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ), // Center Stage Width
          child: Obx(() {
            // Check if a post is selected
            if (controller.selectedPost.value != null) {
              return DesktopPostDetailsWrapper(
                post: controller.selectedPost.value!,
              );
            }

            return CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                // 1. The Posts List
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 40, top: 16),
                  sliver: PostsListWidget(controller: controller),
                ),

                SliverToBoxAdapter(
                  child: Obx(
                    () => controller.isPaginationLoading.value
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: context.primary,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ================== Right Panel (Trending & Suggestions) ==================

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.onSurface.withOpacity(0.05)),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending
            Text(
              context.s.community_trending_topics,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendingItem(context, "EGX30", "12.5K posts", "+1.2%", true),
            _buildTrendingItem(
              context,
              "CIB (COMI)",
              "5.2K posts",
              "-0.5%",
              false,
            ),
            _buildTrendingItem(
              context,
              "Gold 21k",
              "Trending in Egypt",
              "",
              true,
            ),

            const SizedBox(height: 32),

            // Who to follow
            Text(
              context.s.community_who_to_follow,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(context, "Ahmed Khalil", "@ahmed_k • Analyst"),
            _buildSuggestionItem(
              context,
              "Mohamed Heiba",
              "@heiba_dev • Developer",
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets

  Widget _buildMiniStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingItem(
    BuildContext context,
    String title,
    String subtitle,
    String change,
    bool isPositive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          if (change.isNotEmpty)
            Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String name,
    String handle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.onSurface.withOpacity(0.1),
            child: Icon(Icons.person, size: 20, color: context.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  handle,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.onSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.s.community_follow,
              style: TextStyle(
                color: context.background,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
