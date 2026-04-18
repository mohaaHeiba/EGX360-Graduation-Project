import 'package:egx/features/auth/data/datasources/local_auth_datasource.dart';
import 'package:egx/features/auth/data/datasources/remote_auth_datasource.dart';
import 'package:egx/features/auth/data/repository/auth_repository_impl.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:get/get.dart';

import 'package:egx/features/auth/domain/repository/auth_repository.dart';
import 'package:egx/core/services/media_service.dart';
import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';
import 'package:egx/features/profile/domain/usecase/get_profile_stats_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaService>(() => MediaService());

    Get.lazyPut<RemoteAuthDatasource>(
      () => RemoteAuthDatasourceImpl(),
      fenix: true,
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(),
      fenix: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
      permanent: true,
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        authRepository: Get.find<AuthRepository>(),

        mediaService: Get.find<MediaService>(),
      ),
    );

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
  }
}
