import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

Widget buildPostsList(
  dynamic controller,
  BuildContext context, {
  required RxList<PostEntity> posts,
  bool isViewedPost = false,
  bool hasNestedScrollView = true,
}) {
  return Obx(() {
    // 1. حالة التحميل (Loading)
    if (controller.isPostsLoading.value) {
      return CustomScrollView(
        slivers: [
          if (hasNestedScrollView)
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
          SliverPadding(
            // شيلنا الـ Padding اللي فوق (16) عشان يبدأ من الأول
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildPostShimmerItem(context),
                childCount: 5,
              ),
            ),
          ),
        ],
      );
    }

    // 2. حالة القائمة الفارغة (Empty)
    if (posts.isEmpty) {
      return CustomScrollView(
        slivers: [
          if (hasNestedScrollView)
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 60,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  AppGaps.h12,
                  const Text(
                    "No posts shared yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 3. عرض البيانات (Data)
    return CustomScrollView(
      slivers: [
        if (hasNestedScrollView)
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 80), // Padding 0 للجوانب
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              return buildPostItem(context, post, controller, index);
            }, childCount: posts.length),
          ),
        ),
      ],
    );
  });
}

// --- Shimmer Widget (Seamless Style) ---
Widget buildPostShimmerItem(BuildContext context) {
  // تعريف الألوان جوه الدالة
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

  return Container(
    // شيلنا المارجن عشان يبقى Seamless
    color: context.surface.withOpacity(0.05), // لون خلفية خفيف جداً
    child: Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 14, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),

          // Image Shimmer (Square & Full Width)
          Container(height: 250, width: double.infinity, color: Colors.white),

          // Content Shimmer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 200, height: 16, color: Colors.white),
              ],
            ),
          ),

          // Footer Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(width: 60, height: 20, color: Colors.white),
                const SizedBox(width: 20),
                Container(width: 60, height: 20, color: Colors.white),
              ],
            ),
          ),

          // External Divider
          Divider(color: Colors.grey.withOpacity(0.1), height: 1),
        ],
      ),
    ),
  );
}

// --- Real Post Widget (Seamless Style) ---
Widget buildPostItem(
  BuildContext context,
  PostEntity post,
  dynamic controller,
  int index,
) {
  return GestureDetector(
    onTap: () {
      Get.toNamed(AppPages.showDetailsPage, arguments: post);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==============================
        // 1. Header (User Info) - تمت إضافته
        // ==============================
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image:
                      (post.userAvatar != null && post.userAvatar!.isNotEmpty)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(post.userAvatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (post.userAvatar == null || post.userAvatar!.isEmpty)
                    ? Center(
                        child: Text(
                          post.userName?.substring(0, 1).toUpperCase() ?? "U",
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userName ?? "User",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: context.onSurface,
                    ),
                  ),
                  Text(
                    "2h ago", // استبدلها بالـ logic بتاع الوقت
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ==============================
        // 2. Image (Full Width & Sharp)
        // ==============================
        if (post.imageUrl != null)
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300, // زودنا الطول شوية عشان الشكل
              minHeight: 200,
            ),
            child: SizedBox(
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: context.isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: context.isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

        // ==============================
        // 3. Tags (Sentiment & Cashtags)
        // ==============================
        if (post.sentiment != null ||
            (post.cashtags != null && post.cashtags!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (post.sentiment != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: post.sentiment == 'bullish'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: post.sentiment == 'bullish'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.sentiment == 'bullish'
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: post.sentiment == 'bullish'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.sentiment == 'bullish' ? "Bullish" : "Bearish",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: post.sentiment == 'bullish'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Cashtags logic...
              ],
            ),
          ),

        // ==============================
        // 4. Content Text
        // ==============================
        if (post.content != null && post.content!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.headline.isNotEmpty)
                  Text(
                    post.headline,
                    style: TextStyle(
                      height: 1.3,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.onSurface,
                    ),
                  ),
                if (post.headline.isEmpty)
                  Text(
                    post.body.isNotEmpty ? post.body : post.content!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 15,
                      color: context.onSurface.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),

        // ==============================
        // 5. Buttons (No Top Divider)
        // ==============================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _buildInteractionBtn(
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: "${post.likesCount}",
                color: post.isLiked ? Colors.red : Colors.grey.shade600,
                onTap: () => controller.toggleLike(index),
              ),
              _buildInteractionBtn(
                icon: Icons.chat_bubble_outline_rounded,
                label: "${post.commentsCount}",
                color: Colors.blueAccent, // أو استخدم AppColors لو عندك
                onTap: () {},
              ),
              const Spacer(),
              IconButton(
                onPressed: () => controller.toggleBookmark(index),
                icon: Icon(
                  post.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 22,
                  color: post.isBookmarked
                      ? context.primary
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // ==============================
        // 6. External Divider (Bottom)
        // ==============================
        Divider(
          color: Colors.grey.withOpacity(0.15), // لون هادي للفاصل
          thickness: 1,
          height: 1,
        ),
      ],
    ),
  );
}

Widget _buildInteractionBtn({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          AppGaps.w8,
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}
