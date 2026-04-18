import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/auth/domain/repository/auth_repository.dart';
import 'package:egx/features/community/data/datasources/community_remote_data_source.dart';
import 'package:egx/features/community/data/repositories/community_repository_impl.dart';
import 'package:egx/features/community/domain/repositories/community_repository.dart';
import 'package:egx/features/community/domain/usecase/get_all_posts_usecase.dart';
import 'package:egx/features/community/domain/usecase/get_stocks_usecase.dart';
import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';
import 'package:egx/features/notifications/domain/usecase/get_peer_fcm_token_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/send_notification_usecase.dart';
import 'package:egx/features/post_details/presentation/controller/post_details_controller.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';
import 'package:egx/features/profile/domain/usecase/get_post_usecase.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityBindings extends Bindings {
  @override
  void dependencies() {
    // Community Data Source
    Get.lazyPut<CommunityRemoteDataSource>(
      () => CommunityRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Community Repository
    Get.lazyPut<CommunityRepository>(
      () => CommunityRepositoryImpl(
        remoteDataSource: Get.find<CommunityRemoteDataSource>(),
      ),
    );

    // Profile Data Source (for interaction use cases)
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Profile Repository (for interaction use cases)
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: Get.find<ProfileRemoteDataSource>(),
        localData: Get.find<InitLocalData>(),
      ),
    );

    // Community Use Cases
    Get.lazyPut(() => GetAllPostsUseCase(Get.find<CommunityRepository>()));
    Get.lazyPut(() => CommunityController());

    // Interaction Use Cases (for like/bookmark)
    Get.lazyPut(() => TogglePostVoteUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => ToggleBookmarkUseCase(Get.find<ProfileRepository>()));
    Get.put(GetStocksUseCase(Get.find<CommunityRepository>()));

    // Post Details Dependencies for Desktop View
    Get.lazyPut(() => GetCommentsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => AddCommentUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => ToggleCommentVoteUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetPostUseCase(Get.find<ProfileRepository>()));

    // Notifications (Assuming AuthRepository and NotificationRepository are available globally or in LayoutBinding)
    // If not found, these might throw error on runtime.
    // We try to find them, if they are not in binding tree, we might need to put them.
    // However, usually AuthRepository is available early on.
    if (Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => GetPeerFcmTokenUseCase(Get.find<AuthRepository>()));
    }
    if (Get.isRegistered<NotificationRepository>()) {
      Get.lazyPut(
        () => SendNotificationUseCase(Get.find<NotificationRepository>()),
      );
    }

    // Controller
    Get.lazyPut(() => PostDetailsController());
  }
}
