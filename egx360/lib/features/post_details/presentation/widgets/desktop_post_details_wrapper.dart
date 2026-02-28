import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/post_details/presentation/widgets/post_details_view.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:egx/features/post_details/presentation/widgets/comment_thread_view.dart';
import 'package:get/get.dart';

class DesktopPostDetailsWrapper extends StatefulWidget {
  final PostEntity post;

  const DesktopPostDetailsWrapper({super.key, required this.post});

  @override
  State<DesktopPostDetailsWrapper> createState() =>
      _DesktopPostDetailsWrapperState();
}

class _DesktopPostDetailsWrapperState extends State<DesktopPostDetailsWrapper> {
  // We use a unique tag to avoid conflict with the main controller if desired,
  // but if we only show one details view at a time, main instance is fine.
  // Using main instance allows shared state easily.
  final PostDetailsController controller = Get.find<PostDetailsController>();

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void didUpdateWidget(covariant DesktopPostDetailsWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _loadPost();
    }
  }

  void _loadPost() {
    controller.loadPost(widget.post);
  }

  // No dispose here because we are reusing the singleton controller
  // passed from binding/Get.find. If we wanted transient, we'd put/delete.

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeThread = controller.activeThread.value;
      final isThreadView = activeThread != null;

      return Column(
        children: [
          // Header with Back Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (isThreadView) {
                      controller.setActiveThread(null);
                      controller
                          .cancelReply(); // Also clear input reply state if any
                    } else {
                      Get.find<CommunityController>().clearSelectedPost();
                    }
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  isThreadView ? "Replies" : "Post",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isThreadView
                ? CommentThreadView(
                    controller: controller,
                    rootComment: activeThread,
                  )
                : PostDetailsView(controller: controller),
          ),
        ],
      );
    });
  }
}
