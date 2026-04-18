import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class GetFollowingUseCase {
  final ProfileRepository repository;

  GetFollowingUseCase(this.repository);

  Future<List<AuthEntity>> call(String userId) {
    return repository.getFollowing(userId);
  }
}
