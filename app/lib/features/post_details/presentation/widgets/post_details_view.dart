import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/post_details/presentation/page/comment_thread_page.dart';
import 'package:egx/features/post_details/presentation/widgets/build_input_section.dart';
import 'package:egx/features/post_details/presentation/widgets/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/generated/l10n.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsView extends StatelessWidget {
  final PostDetailsController controller;

  const PostDetailsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // A. Post Header Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(0),
                  child: Obx(() {
                    if (controller.isPostLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final post = controller.post.value;
                    // If post is null, just show empty
                    if (post == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ============================
                        // User Info Header + Sentiment
                        // ============================
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. User Info (Left Side)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    final userEntity = AuthEntity(
                                      id: post.userId,
                                      name:
                                          post.userName ??
                                          S
                                              .of(context)
                                              .post_details_user_fallback,
                                      email: '',
                                      avatarUrl: post.userAvatar,
                                    );
                                    Get.toNamed(
                                      AppPages.userProfilePage,
                                      arguments: userEntity,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color:
                                              (post.userAvatar == null ||
                                                  post.userAvatar!.isEmpty)
                                              ? context.primary.withOpacity(
                                                  0.15,
                                                )
                                              : Colors.transparent,
                                          image:
                                              (post.userAvatar != null &&
                                                  post.userAvatar!.isNotEmpty)
                                              ? DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                        post.userAvatar!,
                                                      ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child:
                                            (post.userAvatar == null ||
                                                post.userAvatar!.isEmpty)
                                            ? Center(
                                                child: Text(
                                                  post.userName
                                                          ?.substring(0, 1)
                                                          .toUpperCase() ??
                                                      S
                                                          .of(context)
                                                          .post_details_user_fallback
                                                          .substring(0, 1),
                                                  style: TextStyle(
                                                    color: context.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Name & Time
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.userName ??
                                                  S
                                                      .of(context)
                                                      .post_details_user_fallback,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              timeago.format(post.createdAt),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 2. Sentiment Badge (Right Side)
                              if (post.sentiment != null)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: post.sentiment == 'bullish'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: post.sentiment == 'bullish'
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.red.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        post.sentiment == 'bullish'
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        size: 16,
                                        color: post.sentiment == 'bullish'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.sentiment == 'bullish'
                                            ? S.of(context).post_details_bullish
                                            : S
                                                  .of(context)
                                                  .post_details_bearish,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: post.sentiment == 'bullish'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Image & Content
                        if (post.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  child: CachedNetworkImage(
                                    imageUrl: post.imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                // Cashtags Overlay
                                if (post.cashtags != null &&
                                    post.cashtags!.isNotEmpty)
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: post.cashtags!.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        if (post.content != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (post.headline.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      post.headline,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                    ),
                                  ),
                                Text(
                                  post.headline.isNotEmpty
                                      ? post.body
                                      : post.content!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Actions
                        Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ActionButton(
                                icon: post.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                count: post.likesCount,
                                color: post.isLiked
                                    ? Colors.red
                                    : Colors.grey[600]!,
                                onTap: controller.toggleLike,
                              ),
                              ActionButton(
                                icon: Icons.chat_bubble_outline_rounded,
                                count: post.commentsCount,
                                color: AppColors.candleGreen.withOpacity(0.5),
                                isActive: false,
                              ),
                              IconButton(
                                onPressed: controller.toggleBookmark,
                                icon: Icon(
                                  post.isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: post.isBookmarked
                                      ? AppColors.candleGreen
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // B. Comments Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        S.of(context).post_details_comments_header,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${controller.comments.length}",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // C. Comments List (ROOTS ONLY)
              Obx(() {
                if (controller.isLoadingComments.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                // Use rootComments only
                final commentsList = controller.rootComments;

                if (commentsList.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              S.of(context).post_details_no_comments,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final comment = commentsList[index];

                    return Column(
                      children: [
                        CommentItem(
                          comment: comment,
                          isReplyingTo:
                              controller.replyingTo.value?.id == comment.id,
                          repliesCount: controller.getReplyCount(comment.id),

                          onViewReplies: () {
                            controller.setReplyTo(comment);
                            if (ResponsiveLayout.isDesktop(context)) {
                              controller.setActiveThread(comment);
                            } else {
                              Get.to(
                                () => CommentThreadPage(rootComment: comment),
                              );
                            }
                          },

                          onVote: (voteType) {
                            final originalIndex = controller.comments
                                .indexWhere((c) => c.id == comment.id);
                            if (originalIndex != -1) {
                              controller.toggleCommentVote(
                                originalIndex,
                                voteType,
                              );
                            }
                          },
                          onReply: () {
                            controller.setReplyTo(comment);
                            if (ResponsiveLayout.isDesktop(context)) {
                              controller.setActiveThread(comment);
                            } else {
                              Get.to(
                                () => CommentThreadPage(rootComment: comment),
                              );
                            }
                          },
                        ),
                        if (index < commentsList.length - 1)
                          Divider(
                            height: 1,
                            indent: 70,
                            endIndent: 20,
                            color: Colors.grey.withOpacity(0.1),
                          ),
                      ],
                    );
                  }, childCount: commentsList.length),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),

        BuildInputSection(controller: controller),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;

  const ActionButton({
    super.key,
    required this.icon,
    required this.count,
    required this.color,
    this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 6),
          Text(
            "$count",
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
