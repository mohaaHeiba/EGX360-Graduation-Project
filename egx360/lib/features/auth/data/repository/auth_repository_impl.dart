import 'package:egx/core/errors/app_exception.dart';
import 'package:egx/features/auth/data/datasources/local_auth_datasource.dart';
import 'package:egx/features/auth/data/datasources/remote_auth_datasource.dart';
import 'package:egx/features/auth/data/model/auth_model.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDatasource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthEntity> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. تسجيل في السيرفر
    final userModel = await remoteDataSource.signUp(
      name: name,
      email: email,
      password: password,
    );

    // 2. تخزين في الكاش (عشان يبقى مسجل دخول)
    await localDataSource.cacheAuthData(userModel);

    return userModel;
  }

  @override
  Future<AuthEntity> signIn({
    required String email,
    required String password,
  }) async {
    // 1. دخول من السيرفر
    final userModel = await remoteDataSource.signIn(
      email: email,
      password: password,
    );

    // 2. تحديث الكاش بالبيانات الجديدة
    await localDataSource.cacheAuthData(userModel);

    return userModel;
  }

  @override
  Future<AuthEntity> googleSignIn() async {
    final userModel = await remoteDataSource.googleSignIN();

    // تخزين البيانات بعد الدخول بجوجل
    await localDataSource.cacheAuthData(userModel);

    return userModel;
  }

  @override
  Future<void> logout() async {
    // 1. خروج من السيرفر
    await remoteDataSource.logout();

    // 2. مسح البيانات من الكاش
    await localDataSource.clearAuthData();
  }

  @override
  Future<AuthEntity?> getCurrentUser() async {
    // بنجيب اليوزر من الداتابيز المحلية (Floor)
    return await localDataSource.getAuthData();
  }

  @override
  Future<bool> isEmailVerified() async {
    return await remoteDataSource.isEmailVerified();
  }

  @override
  Future<void> resetPassword(String email) async {
    await remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await remoteDataSource.updatePassword(newPassword);
  }

  @override
  Future<void> updateUserData(AuthEntity user) async {
    try {
      final userModel = AuthModel(
        id: user.id,
        name: user.name,
        email: user.email,
        bio: user.bio,
        avatarUrl: user.avatarUrl,
        lastActiveAtDate: DateTime.now(),
        createdAtDate: user.createdAt != null
            ? DateTime.tryParse(user.createdAt!)
            : null,
        updatedAtDate: DateTime.now(),
      );

      await remoteDataSource.updateUserData(userModel);

      await localDataSource.cacheAuthData(userModel);
    } catch (e) {
      throw AuthAppException(e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    await remoteDataSource.changePassword(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await remoteDataSource.deleteAccount(userId);
    // لو الحساب اتمسح، لازم ننظف الكاش برضه
    await localDataSource.clearAuthData();
  }

  @override
  Future<String?> getUserFcmToken(String userId) async {
    return await remoteDataSource.getUserFcmToken(userId);
  }
}
