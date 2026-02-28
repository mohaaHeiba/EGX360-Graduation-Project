import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

Widget buildUserInfo(BuildContext context, AuthEntity user, final controller) {
  return Row(
    children: [
      Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(color: context.surface.withOpacity(0.8), width: 1),
          image: (user.avatarUrl!.isNotEmpty)
              ? DecorationImage(
                  image: CachedNetworkImageProvider(user.avatarUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: (user.avatarUrl!.isEmpty)
            ? Center(
                child: Text(
                  (user.name.isNotEmpty) ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "@${user.name.replaceAll(' ', '').toLowerCase()}",
                style: TextStyle(
                  fontSize: 12,
                  color: context.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
