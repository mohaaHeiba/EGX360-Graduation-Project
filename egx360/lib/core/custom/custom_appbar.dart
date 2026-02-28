import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

PreferredSizeWidget? customAppbar(
  final VoidCallback backm,
  String title, {
  final bool isActions = false,
  final bool withIcon = false,
  final IconData iconData = Icons.auto_awesome,
}) {
  // فحص إذا كان العرض ديسكتوب أو تابلت لإخفاء الـ AppBar
  // نستخدم Get.context!.isDesktop أو فحص العرض مباشرة
  // if (Platform.isLinux ||
  //     Platform.isWindows ||
  //     Platform.isMacOS ||
  //     // Platform.isWeb ||
  //     Get.context!.width > 900) {
  //   return null;
  // }

  return AppBar(
    toolbarHeight: 80,
    backgroundColor: Theme.of(Get.context!).colorScheme.background,
    elevation: 0,
    leadingWidth: 80,
    leading: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Center(
          child: Container(
            margin: const EdgeInsets.only(left: 0.0),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: backm,
            ),
          ),
        );
      },
    ),
    title: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return withIcon
            ? Row(
                children: [
                  Icon(
                    iconData,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
      },
    ),
    actions: [
      if (isActions)
        IconButton(
          onPressed: () => Get.toNamed(AppPages.savedPosts),
          icon: const Icon(Icons.bookmark_border_rounded),
        ),
    ],
  );
}
