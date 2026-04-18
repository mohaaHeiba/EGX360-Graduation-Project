import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/features/post_details/domain/entity/comment_entity.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/post_details/presentation/widgets/comment_thread_view.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentThreadPage extends GetView<PostDetailsController> {
  final CommentEntity rootComment;

  const CommentThreadPage({super.key, required this.rootComment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.cancelReply();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: customAppbar(
          Get.back,
          S.of(context).post_details_replies_title,
        ),
        body: CommentThreadView(
          controller: controller,
          rootComment: rootComment,
        ),
      ),
    );
  }
}
