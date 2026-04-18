import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/notifications/presentation/controller/notification_controller.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:egx/features/home/presentation/widgets/shared/logo_animation.dart';

import 'package:get/get.dart';

class HomeIdentityHeader extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;

  HomeIdentityHeader({this.expandedHeight = 115, this.collapsedHeight = 65});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (expandedHeight - collapsedHeight)).clamp(
      0.0,
      1.0,
    );

    final welcomeOpacity = (1.0 - (progress * 2.5)).clamp(0.0, 1.0);

    final logoTranslateY = 15 * (1 - progress);

    return Container(
      color: context.background,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 25,
            left: 0,
            child: Opacity(
              opacity: welcomeOpacity,
              child: Obx(() {
                final name =
                    Get.find<SettingsController>().currentUser.value?.name ??
                    ' ';
                return Text(
                  context.s.home_greeting(name),
                  style: TextStyle(
                    color: context.onSurface.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
            ),
          ),

          Positioned(
            left: 0,
            bottom: 15 + logoTranslateY,
            child: const EGXLogoStackLoop(),
          ),

          Positioned(right: 0, bottom: 18, child: _buildActionButtons(context)),
        ],
      ),
    );
  }

  /// Row with chatbot button + notification button.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChatbotButton(context),
        const SizedBox(width: 8),
        _buildNotificationButton(context),
      ],
    );
  }

  Widget _buildChatbotButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppPages.chatbotPage),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.onSurface.withOpacity(0.1)),
        ),

        child: Icon(
          Icons.smart_toy_rounded,
          color: context.onSurface,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppPages.notificationPage);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.onSurface.withOpacity(0.1)),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: context.onSurface.withOpacity(0.8),
              size: 20,
            ),
          ),
          // Unread count badge
          if (Get.isRegistered<NotificationController>())
            Obx(() {
              final count = Get.find<NotificationController>().unreadCount;
              if (count == 0) return const SizedBox.shrink();

              return Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.background, width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => collapsedHeight;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
