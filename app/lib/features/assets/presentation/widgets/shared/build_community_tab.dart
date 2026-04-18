import 'package:egx/features/community/presentation/widgets/build_post_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

Widget buildCommunityTab(dynamic controller) {
  // final controller = Get.find<StockDetailsController>(); // Removed

  return Obx(() {
    if (controller.isLoadingPosts.value && controller.postsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.postsList.isEmpty) {
      return Center(
        child: Text(
          "No posts yet for this stock",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!controller.isLoadMore.value &&
            controller.hasMore.value &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          controller.loadMorePosts();
        }
        return false;
      },
      child: ListView.builder(
        itemCount:
            controller.postsList.length + (controller.hasMore.value ? 1 : 0),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          if (index == controller.postsList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final post = controller.postsList[index];
          return PostCard(post: post, index: index, controller: controller);
        },
      ),
    );
  });
}
