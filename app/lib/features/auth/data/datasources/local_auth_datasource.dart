import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:get/get.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthData(AuthEntity authEntity);
  Future<AuthEntity?> getAuthData();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final InitLocalData _localData = Get.find<InitLocalData>();

  @override
  Future<void> cacheAuthData(AuthEntity authEntity) async {
    await _localData.saveAuthData(authEntity);
  }

  @override
  Future<AuthEntity?> getAuthData() async {
    return await _localData.getAuthData();
  }

  @override
  Future<void> clearAuthData() async {
    await _localData.clearAuthData();
  }
}
