import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/profile/domain/usecase/create_post_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_profile_stats_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_user_posts_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_user_profile_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_viewed_user_posts_usecase.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/features/profile/presentations/controller/profile_controller.dart';
import 'package:egx/features/profile/presentations/controller/view_profile_controller.dart';
import 'package:egx/features/profile/presentations/controller/follow_list_controller.dart';
import 'package:egx/features/profile/domain/usecase/get_followers_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_following_usecase.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';
import 'package:egx/features/profile/domain/usecase/get_saved_posts_usecase.dart';
import 'package:egx/features/profile/presentations/controller/saved_posts_controller.dart';

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(Supabase.instance.client),
    );

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: Get.find<ProfileRemoteDataSource>(),
        localData: Get.find<InitLocalData>(),
      ),
    );

    Get.lazyPut(() => GetProfileStatsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetUserPostsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetViewedUserPostsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetUserProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => CreatePostUseCase(Get.find<ProfileRepository>()));

    Get.lazyPut(() => TogglePostVoteUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetCommentsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => AddCommentUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => ToggleBookmarkUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => ToggleFollowUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => CheckFollowStatusUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(
      () => ProfileToggleWatchlistUseCase(Get.find<ProfileRepository>()),
    );
    Get.lazyPut(() => GetUserWatchlistUseCase(Get.find<ProfileRepository>()));

    Get.lazyPut(() => ToggleCommentVoteUseCase(Get.find<ProfileRepository>()));

    Get.lazyPut(() => GetFollowersUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetFollowingUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetSavedPostsUseCase(Get.find<ProfileRepository>()));

    Get.lazyPut(
      () => FollowListController(
        getFollowersUseCase: Get.find<GetFollowersUseCase>(),
        getFollowingUseCase: Get.find<GetFollowingUseCase>(),
        toggleFollowUseCase: Get.find<ToggleFollowUseCase>(),
        checkFollowStatusUseCase: Get.find<CheckFollowStatusUseCase>(),
      ),
    );

    Get.put(ProfileController());
    Get.lazyPut(() => ViewProfileController());
    Get.lazyPut(
      () => SavedPostsController(
        getSavedPostsUseCase: Get.find<GetSavedPostsUseCase>(),
        toggleBookmarkUseCase: Get.find<ToggleBookmarkUseCase>(),
        togglePostVoteUseCase: Get.find<TogglePostVoteUseCase>(),
      ),
    );
  }
}
