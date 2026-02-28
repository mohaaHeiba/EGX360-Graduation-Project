import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';

import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/edit_Profile/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget buildActionButtons(
  dynamic controller,
  AuthEntity displayUser,
  BuildContext theme,
) {
  final String currentUserId =
      Supabase.instance.client.auth.currentUser?.id ?? '';
  final bool isOwnProfile = displayUser.id == currentUserId;

  if (isOwnProfile) {
    // Own profile - Show Edit and Share buttons (no reactivity needed)
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Get.to(EditProfilePage(), transition: Transition.rightToLeft);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Edit",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        AppGaps.w12,
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: () {
                // Share post content + optional link
                final text = displayUser.bio ?? "";
                final url = displayUser.avatarUrl ?? "";

                Share.share(url.isNotEmpty ? "$text\n\n$url" : text);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Share", style: TextStyle(color: theme.onSurface)),
            ),
          ),
        ),
      ],
    );
  } else {
    // Other user's profile - Show Follow/Following button (needs reactivity)
    return Obx(() {
      return SizedBox(
        height: 45,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isCheckingFollow.value
              ? null
              : () => controller.toggleFollow(displayUser.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isFollowing.value
                ? Colors.grey.shade300
                : theme.primary,
            foregroundColor: controller.isFollowing.value
                ? Colors.black87
                : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: controller.isCheckingFollow.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  controller.isFollowing.value ? "Following" : "Follow",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      );
    });
  }
}
