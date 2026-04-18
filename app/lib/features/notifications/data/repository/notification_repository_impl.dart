import 'package:egx/features/notifications/data/datasource/notification_remote_datasource.dart';
import 'package:egx/features/notifications/domain/entity/notification_entity.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    return await remoteDataSource.getNotifications(page: page, limit: limit);
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await remoteDataSource.markAllAsRead(userId);
  }

  @override
  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await remoteDataSource.sendNotification(
      token: token,
      title: title,
      body: body,
      data: data,
    );
  }
}
