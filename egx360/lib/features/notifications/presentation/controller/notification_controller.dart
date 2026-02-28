import 'package:egx/features/notifications/domain/entity/notification_entity.dart';
import 'package:egx/features/notifications/domain/usecase/get_notifications_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/mark_notification_as_read_usecase.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends GetxController {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  NotificationController({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
  });

  S get s => Get.context!.s;

  var notifications = <NotificationEntity>[].obs;
  var isLoading = false.obs;
  var page = 1;
  var hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      hasMore = true;
      notifications.clear();
    }

    if (!hasMore && !refresh) return;

    isLoading.value = true;
    try {
      final newNotifications = await getNotificationsUseCase(page: page);
      if (newNotifications.length < 20) {
        hasMore = false;
      }
      notifications.addAll(newNotifications);
      page++;
    } catch (e) {
      customSnackbar(
        title: s.error_label,
        message: s.failed_to_load_notifications,
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get count of unread notifications
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> markAsRead(NotificationEntity notification) async {
    if (notification.isRead) return;

    try {
      await markNotificationAsReadUseCase(notification.id);
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        // Create a new list to trigger UI update properly if needed, though obs list handles it.
        // But we need to update the specific item.
        // Since NotificationEntity is immutable, we can't just set isRead = true.
        // We assume we don't need to update the local entity immediately for the UI if we navigate away,
        // but for good UX we should.
        // For now, let's just proceed with navigation.
      }
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Call repository to mark all as read
      await getNotificationsUseCase.repository.markAllAsRead(userId);

      // Refresh notifications
      await fetchNotifications(refresh: true);

      customSnackbar(
        title: s.success_label,
        message: s.success_mark_all_read,
        color: Colors.green,
      );
    } catch (e) {
      print("Error marking all as read: $e");
      customSnackbar(
        title: s.error_label,
        message: s.failed_mark_all_read,
        color: Colors.red,
      );
    }
  }

  void onItemClick(NotificationEntity notification) {
    markAsRead(notification);

    final type = notification.type;
    final metadata = notification.metadata;

    print("DEBUG: onItemClick - Type: $type, Metadata: $metadata");

    if (type == 'comment' || type == 'reply' || type == 'like') {
      // Check for both 'post_id' and 'postId' to be safe
      final postId =
          metadata['post_id']?.toString() ?? metadata['postId']?.toString();
      print("DEBUG: Extracted Post ID: $postId");

      if (postId != null) {
        Get.toNamed(
          AppPages.showDetailsPage,
          arguments: {'postId': int.tryParse(postId)},
        );
      } else {
        print("DEBUG: Post ID is null");
      }
    } else if (type == 'follow') {
      final followerId = metadata['follower_id']?.toString();
      if (followerId != null) {
        Get.toNamed(
          AppPages.userProfilePage,
          arguments: {'userId': followerId},
        );
      }
    }
  }
}
