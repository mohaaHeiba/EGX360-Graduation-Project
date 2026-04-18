import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/post_details/presentation/widgets/post_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostDetailsPage extends GetView<PostDetailsController> {
  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If arguments are passed, controller.onInit will handle loading.
    // If not (e.g. desktop manual loading), we might need to handle it differently,
    // but for this Page (Mobile mainly), it relies on Get arguments.

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(Get.back, "Post Details"),
      body: PostDetailsView(controller: controller),
    );
  }
}
