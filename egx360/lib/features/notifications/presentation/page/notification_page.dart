import 'package:egx/features/notifications/presentation/controller/notification_controller.dart';
import 'package:egx/features/notifications/domain/entity/notification_entity.dart';
import 'package:egx/features/notifications/presentation/widgets/notification_item.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          leadingWidth: 80,
          leading: Center(
            child: Container(
              margin: const EdgeInsets.only(left: 0.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
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
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: Text(
            context.s.notifications_title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Obx(() {
              if (controller.unreadCount == 0) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => controller.markAllAsRead(),
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(context.s.mark_all_read_btn),
              );
            }),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(child: Text(context.s.no_notifications_msg));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(refresh: true),
          child: ListView.builder(
            itemCount:
                controller.notifications.length + (controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                controller.fetchNotifications();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final notification = controller.notifications[index];
              return NotificationItem(
                notification: notification,
                onTap: () => controller.onItemClick(notification),
              );
            },
          ),
        );
      }),
    );
  }
}
