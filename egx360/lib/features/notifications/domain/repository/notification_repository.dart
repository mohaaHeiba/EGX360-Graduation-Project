import 'package:egx/features/notifications/domain/entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({
    int page = 1,
    int limit = 20,
  });
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  });
}
