import 'package:egx/features/notifications/domain/repository/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<void> call(int notificationId) {
    return repository.markAsRead(notificationId);
  }
}
