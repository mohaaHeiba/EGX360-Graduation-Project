import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class GetPostUseCase {
  final ProfileRepository repository;

  GetPostUseCase(this.repository);

  Future<PostEntity> call(int postId) {
    return repository.getPostById(postId);
  }
}
