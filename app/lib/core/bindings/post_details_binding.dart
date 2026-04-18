import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/features/auth/domain/repository/auth_repository.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';
import 'package:egx/features/notifications/domain/usecase/get_peer_fcm_token_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/send_notification_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_post_usecase.dart';
import 'package:get/get.dart';

class PostDetailsBinding extends Bindings {
  @override
  void dependencies() {
    final authRepo = Get.find<AuthRepository>();
    final notifRepo = Get.find<NotificationRepository>();
    final repo = Get.find<ProfileRepository>();

    Get.lazyPut(() => GetCommentsUseCase(repo));
    Get.lazyPut(() => AddCommentUseCase(repo));
    Get.lazyPut(() => TogglePostVoteUseCase(repo));
    Get.lazyPut(() => ToggleBookmarkUseCase(repo));
    Get.lazyPut(() => ToggleCommentVoteUseCase(repo));
    Get.lazyPut(() => GetPostUseCase(repo));

    Get.lazyPut(() => GetPeerFcmTokenUseCase(authRepo));
    Get.lazyPut(() => SendNotificationUseCase(notifRepo));

    Get.lazyPut(() => PostDetailsController());
  }
}
