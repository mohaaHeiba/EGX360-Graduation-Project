import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class GetSavedPostsUseCase {
  final ProfileRepository repository;
  GetSavedPostsUseCase(this.repository);

  Future<List<PostEntity>> call(String userId) async {
    return await repository.getSavedPosts(userId);
  }
}
