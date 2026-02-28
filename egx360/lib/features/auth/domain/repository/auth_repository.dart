import 'package:egx/features/auth/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  // Authentication
  Future<AuthEntity> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthEntity> signIn({required String email, required String password});

  Future<AuthEntity> googleSignIn();

  Future<void> logout();

  // Local / Session Management
  Future<AuthEntity?> getCurrentUser();

  // Account Management
  Future<bool> isEmailVerified();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> updateUserData(AuthEntity user);
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  });
  Future<void> deleteAccount(String userId);
  Future<String?> getUserFcmToken(String userId);
}
