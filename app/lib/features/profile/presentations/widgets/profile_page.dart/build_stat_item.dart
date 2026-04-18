import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

Widget buildStatItem(
  String value,
  String label,
  BuildContext theme,
  String userId, {
  String userName = "",
}) {
  return Hero(
    tag: 'stats_${label.toLowerCase()}_$userId',
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (label == "Followers") {
            Get.toNamed(
              AppPages.followersFollowingPage,
              arguments: {
                'userId': userId,
                'userName': userName,
                'initialIndex': 0,
              },
            );
          } else if (label == "Following") {
            Get.toNamed(
              AppPages.followersFollowingPage,
              arguments: {
                'userId': userId,
                'userName': userName,
                'initialIndex': 1,
              },
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.onSurface.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
