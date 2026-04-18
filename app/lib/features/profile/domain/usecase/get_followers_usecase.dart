import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class GetFollowersUseCase {
  final ProfileRepository repository;

  GetFollowersUseCase(this.repository);

  Future<List<AuthEntity>> call(String userId) {
    return repository.getFollowers(userId);
  }
}
