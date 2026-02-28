import 'package:egx/features/post_details/domain/entity/comment_entity.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/post_details/presentation/widgets/build_input_section.dart';
import 'package:egx/features/post_details/presentation/widgets/comment_item.dart';
import 'package:egx/features/post_details/presentation/page/comment_thread_page.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentThreadView extends StatelessWidget {
  final PostDetailsController controller;
  final CommentEntity rootComment;

  const CommentThreadView({
    super.key,
    required this.controller,
    required this.rootComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // 1. The Main Root Comment
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Obx(() {
                    final currentRoot = controller.comments.firstWhere(
                      (c) => c.id == rootComment.id,
                      orElse: () => rootComment,
                    );
                    return CommentItem(
                      comment: currentRoot,
                      onVote: (voteType) => _handleVote(currentRoot, voteType),
                      onReply: () {
                        controller.setReplyTo(currentRoot);
                        if (ResponsiveLayout.isDesktop(context)) {
                          controller.setActiveThread(currentRoot);
                        } else {
                          Get.to(
                            () => CommentThreadPage(rootComment: currentRoot),
                          );
                        }
                      },
                      repliesCount: 0,
                      onViewReplies: () {},
                      isReplyingTo:
                          controller.replyingTo.value?.id == currentRoot.id,
                    );
                  }),
                ),
              ),

              // 2. The Replies List
              Obx(() {
                final threadComments = controller.getThreadFor(rootComment.id);

                if (threadComments.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final reply = threadComments[index];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: CommentItem(
                            comment: reply,
                            isReplyingTo:
                                controller.replyingTo.value?.id == reply.id,

                            repliesCount: 0,
                            onViewReplies: () {
                              controller.setReplyTo(reply);
                              if (ResponsiveLayout.isDesktop(context)) {
                                controller.setActiveThread(reply);
                              } else {
                                Get.to(
                                  () => CommentThreadPage(rootComment: reply),
                                );
                              }
                            },

                            onVote: (voteType) => _handleVote(reply, voteType),
                            onReply: () {
                              controller.setReplyTo(reply);
                              if (ResponsiveLayout.isDesktop(context)) {
                                controller.setActiveThread(reply);
                              } else {
                                Get.to(
                                  () => CommentThreadPage(rootComment: reply),
                                );
                              }
                            },
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 70,
                          endIndent: 20,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ],
                    );
                  }, childCount: threadComments.length),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),

        BuildInputSection(controller: controller, canCancelReply: false),
      ],
    );
  }

  void _handleVote(CommentEntity comment, int voteType) {
    final originalIndex = controller.comments.indexWhere(
      (c) => c.id == comment.id,
    );
    if (originalIndex != -1) {
      controller.toggleCommentVote(originalIndex, voteType);
    }
  }
}
