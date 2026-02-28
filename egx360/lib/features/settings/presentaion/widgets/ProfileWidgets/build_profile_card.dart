import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCard extends StatelessWidget {
  final AuthEntity currentUser;

  final int postsCount;
  final int followersCount;
  final int followingCount;

  const ProfileCard({
    super.key,
    required this.currentUser,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final buildTheme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppPages.profilePage, arguments: currentUser);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: BoxDecoration(
          color: theme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.onSurface.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: context.surface.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profile_image_${currentUser.id}',
                  child: CachedNetworkImage(
                    imageUrl: currentUser.avatarUrl ?? "",
                    imageBuilder: (context, imageProvider) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // التعديل هنا لعرض الأيقونة:
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Get.context!.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.candleGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'profile_name_${currentUser.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            currentUser.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Hero(
                        tag: 'profile_email_${currentUser.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            currentUser.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.onSurface.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.onSurface.withOpacity(0.4),
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  postsCount.toString(),
                  context.s.profile_posts,
                  buildTheme,
                ),
                _buildStatItem(
                  followersCount.toString(),
                  context.s.profile_followers,
                  buildTheme,
                ),
                _buildStatItem(
                  followingCount.toString(),
                  context.s.profile_following,
                  buildTheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Hero(
      tag: 'stats_${label.toLowerCase()}_${currentUser.id}',
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
