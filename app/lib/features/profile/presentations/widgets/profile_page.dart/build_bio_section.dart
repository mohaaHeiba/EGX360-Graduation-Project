import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

Widget buildBioSection(
  dynamic controller,
  AuthEntity user,
  BuildContext context,
) {
  return Obx(() {
    final isOwnProfile = user.id == controller.currentUserId;
    final displayUser = isOwnProfile
        ? (controller.userProfile.value ?? user)
        : (controller.userProfile.value?.id == user.id
              ? controller.userProfile.value
              : user);

    final String bio = displayUser?.bio ?? "";

    if (bio.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bio,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: context.onBackground.withOpacity(0.8),
          ),
        ),
      ],
    );
  });
}
