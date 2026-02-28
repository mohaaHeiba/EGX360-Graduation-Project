import 'package:egx/features/notifications/data/datasource/notification_remote_datasource.dart';
import 'package:egx/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';
import 'package:egx/features/notifications/domain/usecase/get_notifications_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/mark_notification_as_read_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/send_notification_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/get_peer_fcm_token_usecase.dart';
import 'package:egx/features/notifications/presentation/controller/notification_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(Get.find()),
    );
    Get.lazyPut(() => GetNotificationsUseCase(Get.find()));
    Get.lazyPut(() => MarkNotificationAsReadUseCase(Get.find()));
    Get.lazyPut(() => SendNotificationUseCase(Get.find()));
    Get.lazyPut(() => GetPeerFcmTokenUseCase(Get.find()));
    Get.lazyPut(
      () => NotificationController(
        getNotificationsUseCase: Get.find(),
        markNotificationAsReadUseCase: Get.find(),
      ),
    );
  }
}
