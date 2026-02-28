import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:egx/features/community/presentation/widgets/build_post_card.dart';
import 'package:egx/features/community/presentation/widgets/shimmer_post_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostsListWidget extends StatelessWidget {
  final CommunityController controller;

  const PostsListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print(
        "PostsListWidget rebuilding. isLoading: ${controller.isLoading.value}, posts: ${controller.posts.length}",
      );

      // 1. Loading state (
      if (controller.isLoading.value) {
        return SliverPadding(
          padding: const EdgeInsets.all(0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: ShimmerPostCard(),
                );
              },
              childCount: 5, // Show 5 loading skeletons
            ),
          ),
        );
      }

      // 2. Empty state
      if (controller.posts.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feed_outlined,
                  size: 60,
                  color: Colors.grey.withOpacity(0.5),
                ),
                AppGaps.h12,
                Text(
                  context.s.community_no_posts,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      // 3. Posts list
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final post = controller.posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: PostCard(post: post, index: index, controller: controller),
          );
        }, childCount: controller.posts.length),
      );
    });
  }
}
