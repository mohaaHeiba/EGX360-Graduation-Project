import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildInputSection extends StatelessWidget {
  final PostDetailsController controller;
  final bool canCancelReply;

  const BuildInputSection({
    super.key,
    required this.controller,
    this.canCancelReply = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Get.find<InitLocalData>().currentUser.value;
    final isDark = theme.brightness == Brightness.dark;

    // Local observable for text content to avoid rebuilding everything
    final hasText = (controller.commentController.text.trim().isNotEmpty).obs;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Replying Indicator (Animated)
          Obx(() {
            final isReplying = controller.replyingTo.value != null;

            return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: !isReplying
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(color: context.primary, width: 4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply_rounded,
                            size: 16,
                            color: context.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S
                                      .of(context)
                                      .post_details_replying_to(
                                        '',
                                      ), // Just the prefix "Replying to"
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  controller.replyingTo.value?.userName ??
                                      S.of(context).post_details_user_fallback,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (canCancelReply)
                            InkWell(
                              onTap: controller.cancelReply,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: context.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            );
          }),

          // 2. Input Row (Avatar + Field + Button)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // --- Avatar ---
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: (currentUser?.avatarUrl == null)
                      ? context.primary.withOpacity(0.15)
                      : Colors.transparent,
                  image: (currentUser?.avatarUrl != null)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            currentUser!.avatarUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (currentUser?.avatarUrl == null)
                    ? Center(
                        child: Text(
                          (currentUser?.name ??
                                  S.of(context).post_details_user_fallback)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // --- TextField ---
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Obx(
                    () => TextField(
                      controller: controller.commentController,
                      onChanged: (value) {
                        hasText.value = value.trim().isNotEmpty;
                      },
                      decoration: InputDecoration(
                        hintText: controller.replyingTo.value != null
                            ? S
                                  .of(context)
                                  .post_details_reply_to_hint(
                                    controller.replyingTo.value?.userName
                                            ?.split(' ')[0] ??
                                        '',
                                  )
                            : S.of(context).post_details_share_thoughts,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),

              // --- Send Button ---
              Obx(() {
                final showButton = hasText.value;
                final isSending = controller.isSendingComment.value;

                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: showButton || isSending ? null : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: context.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isSending
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => controller.addComment(
                                  keepReplyState: !canCancelReply,
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
