import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/features/profile/presentations/controller/saved_posts_controller.dart';
import 'package:egx/features/profile/presentations/widgets/profile_page.dart/build_posts_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedPostsPage extends GetView<SavedPostsController> {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(Get.back, "Saved Posts"),
      body: buildPostsList(
        controller,
        context,
        posts: controller.savedPosts,
        hasNestedScrollView: false,
      ),
    );
  }
}
