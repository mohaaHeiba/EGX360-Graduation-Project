import 'package:egx/features/auth/data/datasources/local_auth_datasource.dart';
import 'package:egx/features/auth/data/datasources/remote_auth_datasource.dart';
import 'package:egx/features/auth/data/repository/auth_repository_impl.dart';
import 'package:egx/features/auth/domain/repository/auth_repository.dart';
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:egx/features/welcome/presentaion/controller/welcome_controller.dart';
import 'package:get/get.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelcomeController(), fenix: true);
    Get.lazyPut<RemoteAuthDatasource>(
      () => RemoteAuthDatasourceImpl(),
      fenix: true,
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(),

      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(() => AuthController(authRepository: Get.find()), fenix: true);
  }
}
