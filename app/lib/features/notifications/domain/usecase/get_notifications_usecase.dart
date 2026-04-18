import 'package:egx/features/notifications/domain/entity/notification_entity.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call({int page = 1, int limit = 20}) {
    return repository.getNotifications(page: page, limit: limit);
  }
}
