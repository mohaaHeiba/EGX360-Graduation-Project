import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/features/post_details/domain/entity/comment_entity.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final Function(int voteType) onVote; // 1: Like, -1: Dislike
  final VoidCallback onReply;
  final bool isReplyingTo; // Show if this comment is being replied to

  final int repliesCount;
  final VoidCallback onViewReplies;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onVote,
    required this.onReply,
    this.isReplyingTo = false,

    required this.repliesCount,
    required this.onViewReplies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String initial = (comment.userName?.isNotEmpty ?? false)
        ? comment.userName![0].toUpperCase()
        : "?";

    final bool isLiked = comment.userVoteType == 1;
    final bool isDisliked = comment.userVoteType == -1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        decoration: isReplyingTo
            ? BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
        padding: isReplyingTo ? const EdgeInsets.all(8) : EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    (comment.userAvatar == null || comment.userAvatar!.isEmpty)
                    ? colorScheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                image:
                    (comment.userAvatar != null &&
                        comment.userAvatar!.isNotEmpty)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(comment.userAvatar!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: (comment.userAvatar == null || comment.userAvatar!.isEmpty)
                  ? Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // 2. Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.userName ??
                            S.of(context).post_details_user_fallback,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        timeago.format(
                          comment.createdAt,
                          locale:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'ar_short'
                              : 'en_short',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Reply indicator
                  if (comment.parentId != null &&
                      comment.parentUserName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            S
                                .of(context)
                                .post_details_replying_to(
                                  comment.parentUserName ?? '',
                                ),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Text
                  Text(
                    comment.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 3. Action Buttons (Reply, Like, Dislike)
                  Row(
                    children: [
                      // Reply Button
                      InkWell(
                        onTap: onReply,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isReplyingTo
                                    ? Icons.reply
                                    : Icons.reply_outlined,
                                size: 14,
                                color: isReplyingTo
                                    ? colorScheme.primary
                                    : colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isReplyingTo
                                    ? S.of(context).post_details_replying
                                    : S.of(context).post_details_reply,
                                style: TextStyle(
                                  color: isReplyingTo
                                      ? colorScheme.primary
                                      : colorScheme.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Like Button
                      InkWell(
                        onTap: () => onVote(1),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.thumb_up_alt_rounded
                                    : Icons.thumb_up_alt_outlined,
                                size: 16,
                                color: isLiked
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                              ),
                              if (comment.likesCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  "${comment.likesCount}",
                                  style: TextStyle(
                                    color: isLiked
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Dislike Button
                      InkWell(
                        onTap: () => onVote(-1),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isDisliked
                                    ? Icons.thumb_down_alt_rounded
                                    : Icons.thumb_down_alt_outlined,
                                size: 16,
                                color: isDisliked
                                    ? Colors.red
                                    : colorScheme.outline,
                              ),
                              if (comment.dislikesCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  "${comment.dislikesCount}",
                                  style: TextStyle(
                                    color: isDisliked
                                        ? Colors.red
                                        : colorScheme.outline,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- 4. View Replies Section ---
                  if (repliesCount > 0) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: onViewReplies,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 1,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              S
                                  .of(context)
                                  .post_details_view_replies(repliesCount),
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
