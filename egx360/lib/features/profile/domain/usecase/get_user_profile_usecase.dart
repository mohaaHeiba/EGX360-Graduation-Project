import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<AuthEntity> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
