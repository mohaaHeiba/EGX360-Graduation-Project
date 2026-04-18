import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/community/domain/entity/stock_entity.dart';
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TRENDING TOPICS ──
            _buildSectionHeader(
              context,
              context.s.community_trending_topics,
              onRefresh: controller.fetchTrendingTopics,
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingTrending.value) {
                return _buildShimmerList(context, 4);
              }
              if (controller.trendingTopics.isEmpty) {
                return _buildEmptyHint(
                  context,
                  context.s.community_trending_topics,
                );
              }
              return Column(
                children: controller.trendingTopics.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key + 1;
                  final topic = entry.value;
                  final symbol = topic['symbol'] as String;
                  final postCount = topic['postCount'] as int;

                  // Try to get change_percent from already-loaded stocks
                  final stock = controller.stocks.firstWhereOrNull(
                    (s) => s.symbol == symbol,
                  );

                  return _buildTrendingTile(
                    context,
                    rank: index,
                    symbol: symbol,
                    postCount: postCount,
                    stock: stock,
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 32),

            // ── WHO TO FOLLOW ──
            _buildSectionHeader(
              context,
              context.s.community_who_to_follow,
              onRefresh: controller.fetchSuggestedUsers,
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingSuggested.value) {
                return _buildShimmerList(context, 3, isUser: true);
              }
              if (controller.suggestedUsers.isEmpty) {
                return _buildEmptyHint(
                  context,
                  context.s.community_who_to_follow,
                );
              }
              return Column(
                children: controller.suggestedUsers.map((user) {
                  return Obx(() {
                    final isFollowing = controller.followedUserIds.contains(
                      user.id,
                    );
                    final isToggling = controller.togglingFollowIds.contains(
                      user.id,
                    );
                    return _buildUserSuggestionTile(
                      context,
                      user: user,
                      isFollowing: isFollowing,
                      isToggling: isToggling,
                      onFollow: () => controller.toggleFollowUser(user.id),
                    );
                  });
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Section header with optional refresh button ──
  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onRefresh,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onRefresh != null)
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.refresh_rounded,
                size: 16,
                color: context.onSurface.withOpacity(0.35),
              ),
            ),
          ),
      ],
    );
  }

  // ── Trending topic tile ──
  Widget _buildTrendingTile(
    BuildContext context, {
    required int rank,
    required String symbol,
    required int postCount,
    StockEntity? stock,
  }) {
    // Try to read change_percent from stock data model.
    // StockEntity only has symbol/logo/sector. The raw change info
    // is on the home StockModel. We'll show post count only here.
    return InkWell(
      onTap: () {
        // Filter the feed to this symbol if it exists in stocks list
        final found = controller.stocks.firstWhereOrNull(
          (s) => s.symbol == symbol,
        );
        if (found != null) {
          controller.toggleStockFilter(found);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? context.primary.withOpacity(0.12)
                    : context.onSurface.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3
                      ? context.primary
                      : context.onSurface.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$$symbol',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$postCount ${postCount == 1 ? "post" : "posts"}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.onSurface.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: context.onSurface.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }

  // ── User suggestion tile ──
  Widget _buildUserSuggestionTile(
    BuildContext context, {
    required dynamic user,
    required bool isFollowing,
    required bool isToggling,
    required VoidCallback onFollow,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.primary.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _avatarFallback(context),
                    )
                  : _avatarFallback(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: context.onSurface.withOpacity(0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Follow / Following button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isFollowing ? Colors.transparent : context.onSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFollowing
                    ? context.onSurface.withOpacity(0.3)
                    : context.onSurface,
              ),
            ),
            child: isToggling
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: context.primary,
                    ),
                  )
                : GestureDetector(
                    onTap: onFollow,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      isFollowing
                          ? context.s.community_following
                          : context.s.community_follow,
                      style: TextStyle(
                        color: isFollowing
                            ? context.onSurface.withOpacity(0.6)
                            : context.background,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(BuildContext context) {
    return Container(
      color: context.primary.withOpacity(0.1),
      child: Icon(Icons.person, size: 20, color: context.primary),
    );
  }

  // ── Shimmer placeholder row ──
  Widget _buildShimmerList(
    BuildContext context,
    int count, {
    bool isUser = false,
  }) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: isUser ? 38 : 24,
                height: isUser ? 38 : 24,
                decoration: BoxDecoration(
                  color: context.onSurface.withOpacity(0.07),
                  shape: isUser ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isUser ? null : BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 11,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.onSurface.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 9,
                      width: 80,
                      decoration: BoxDecoration(
                        color: context.onSurface.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Empty state hint ──
  Widget _buildEmptyHint(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No $label yet',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.onSurface.withOpacity(0.3),
          ),
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
}
