import 'package:egx/features/community/domain/repositories/community_repository.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';

class GetAllPostsUseCase {
  final CommunityRepository repository;
  GetAllPostsUseCase(this.repository);

  Future<List<PostEntity>> call({
    required int limit,
    required int offset,
    String? category,
  }) async {
    return await repository.getAllPosts(
      limit: limit,
      offset: offset,
      category: category,
    );
  }
}
