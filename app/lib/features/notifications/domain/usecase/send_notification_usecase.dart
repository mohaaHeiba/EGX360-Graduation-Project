import 'package:egx/features/notifications/domain/repository/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository repository;

  SendNotificationUseCase(this.repository);

  Future<void> call({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    return repository.sendNotification(
      token: token,
      title: title,
      body: body,
      data: data,
    );
  }
}
