import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/community/domain/entity/stock_entity.dart';
import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrendingAndSuggestionsPanel extends StatelessWidget {
  const TrendingAndSuggestionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommunityController>()) {
      // If controller isn't registered, we just return an empty box
      return const SizedBox();
    }
    final controller = Get.find<CommunityController>();

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

                  final stock = controller.stocks.firstWhereOrNull(
                    (s) => s.symbol == symbol,
                  );

                  return _buildTrendingTile(
                    context,
                    controller: controller,
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

  Widget _buildTrendingTile(
    BuildContext context, {
    required CommunityController controller,
    required int rank,
    required String symbol,
    required int postCount,
    StockEntity? stock,
  }) {
    return InkWell(
      onTap: () {
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
}
