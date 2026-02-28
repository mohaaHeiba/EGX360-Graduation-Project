import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/presentations/widgets/profile_page.dart/build_stat_item.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildHeader(dynamic controller, AuthEntity user, BuildContext context) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return Obx(() {
    final isOwnProfile = user.id == controller.currentUserId;
    final displayUser = isOwnProfile
        ? (controller.userProfile.value ?? user)
        : (controller.userProfile.value?.id == user.id
              ? controller.userProfile.value
              : user);

    final controllerSettins = Get.find<SettingsController>();

    final postsCount = controllerSettins.userStats.value?.postsCount ?? 0;
    final followersCount =
        controllerSettins.userStats.value?.followersCount ?? 0;
    final followingCount =
        controllerSettins.userStats.value?.followingCount ?? 0;

    final String avatarUrl = displayUser?.avatarUrl ?? '';
    final String name = displayUser?.name ?? '';
    final String email = displayUser?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // Align to start so avatar stays at top even if the right column grows
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -------- (1) Avatar --------
            Hero(
              tag: 'profile_image_${user.id}',
              child: Container(
                height: 86,
                width: 86,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white10
                        : Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  image: (avatarUrl.isNotEmpty)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (avatarUrl.isEmpty)
                    ? Center(
                        child: Text(
                          (name.isNotEmpty) ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            AppGaps.w16, // Spacing between Avatar and Info
            /// -------- (2) Name + Email + Stats (Same Column) --------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Name ---
                  Hero(
                    tag: 'profile_name_${user.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // --- Email ---
                  if (email.isEmpty) SizedBox(height: 35, width: 20),
                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: Hero(
                        tag: 'profile_email_${user.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                  // --- Stats (Now inside the same column) ---
                  Obx(() {
                    final stats = controller.userStats.value;
                    return Row(
                      // Distribute space evenly or use start with gaps
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildStatItem(
                          stats?.postsCount.toString() ?? postsCount.toString(),
                          "Posts",
                          context,
                          user.id,
                          userName: name,
                        ),
                        // Removed dividers to save space, but you can add them back if needed
                        buildStatItem(
                          stats?.followersCount.toString() ??
                              followersCount.toString(),
                          "Followers",
                          context,
                          user.id,
                          userName: name,
                        ),
                        buildStatItem(
                          stats?.followingCount.toString() ??
                              followingCount.toString(),
                          "Following",
                          context,
                          user.id,
                          userName: name,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        AppGaps.h20,
      ],
    );
  });
}
