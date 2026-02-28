import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_colors.dart'; // تأكد من استيراد كلاس الألوان
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/presentations/controller/follow_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListItem extends StatelessWidget {
  final AuthEntity user;
  final FollowListController controller;

  const UserListItem({super.key, required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final appTheme = context; // باستخدام الـ extensions اللي عندك
    final isMe = user.id == controller.currentUserId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => Get.toNamed(AppPages.userProfilePage, arguments: user),

      // 1. تظبيط شكل الصورة الشخصية (Avatar)
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14), // حواف دائرية ناعمة (Modern)
          color: context.surface, // خلفية في حالة الصورة لسه بتحمل
          border: Border.all(
            color: context.onSurface.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: user.avatarUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: context.surface),
            errorWidget: (context, url, error) =>
                Icon(Icons.person, color: context.onSurface.withOpacity(0.3)),
          ),
        ),
      ),

      // 2. العنوان (الاسم)
      title: Text(
        user.name,
        style: appTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: context.onBackground,
        ),
      ),

      // 3. الوصف (Bio)
      subtitle: user.bio != null && user.bio!.isNotEmpty
          ? Text(
              user.bio!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTheme.textTheme.bodySmall?.copyWith(
                color: context.onBackground.withOpacity(0.5),
                fontSize: 13,
              ),
            )
          : null,

      // 4. زر المتابعة (Trailing)
      trailing: isMe
          ? null
          : Obx(() {
              final isFollowing = controller.isFollowingMap[user.id] ?? false;
              final isToggling = controller.isTogglingMap[user.id] ?? false;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 95,
                height: 34,
                child: ElevatedButton(
                  onPressed: isToggling
                      ? null
                      : () => controller.toggleFollow(user.id),
                  style: ElevatedButton.styleFrom(
                    // لو متابع: اللون يكون هادي (Surface) | لو مش متابع: اللون يكون فاقع (Primary)
                    backgroundColor: isFollowing
                        ? context.surface
                        : context.primary,

                    // لو متابع: النص أبيض/رصاصي | لو مش متابع: النص أسود (على أخضر البورصة)
                    foregroundColor: isFollowing
                        ? appTheme.onSurface
                        : AppColors.background,

                    elevation: 0,
                    padding: EdgeInsets.zero,
                    side: isFollowing
                        ? BorderSide(color: context.onSurface.withOpacity(0.1))
                        : BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isToggling
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isFollowing
                                ? context.primary
                                : AppColors.background,
                          ),
                        )
                      : Text(
                          isFollowing
                              ? context.s.community_following
                              : context.s.community_follow,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isFollowing
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                ),
              );
            }),
    );
  }
}
