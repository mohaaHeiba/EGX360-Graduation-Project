import 'package:egx/features/post_details/domain/entity/comment_entity.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class TogglePostVoteUseCase {
  final ProfileRepository repository;
  TogglePostVoteUseCase(this.repository);

  Future<void> call(String userId, int postId, int? voteType) async {
    return await repository.togglePostVote(userId, postId, voteType);
  }
}

class GetCommentsUseCase {
  final ProfileRepository repository;
  GetCommentsUseCase(this.repository);

  Future<List<CommentEntity>> call(int postId) async {
    return await repository.getPostComments(postId);
  }
}

class AddCommentUseCase {
  final ProfileRepository repository;
  AddCommentUseCase(this.repository);

  Future<void> call({
    required String userId,
    required int postId,
    required String content,
    int? parentId,
  }) async {
    return await repository.addComment(
      userId: userId,
      postId: postId,
      content: content,
      parentId: parentId,
    );
  }
}

class ToggleCommentVoteUseCase {
  final ProfileRepository repository;
  ToggleCommentVoteUseCase(this.repository);

  Future<void> call(String userId, int commentId, int? voteType) async {
    return await repository.toggleCommentVote(userId, commentId, voteType);
  }
}

class ToggleFollowUseCase {
  final ProfileRepository repository;
  ToggleFollowUseCase(this.repository);

  Future<void> call(String followerId, String followingId) async {
    return await repository.toggleFollow(followerId, followingId);
  }
}

class ToggleBookmarkUseCase {
  final ProfileRepository repository;
  ToggleBookmarkUseCase(this.repository);

  Future<void> call(String userId, int postId) async {
    return await repository.toggleBookmark(userId, postId);
  }
}

class CheckFollowStatusUseCase {
  final ProfileRepository repository;
  CheckFollowStatusUseCase(this.repository);

  Future<bool> call(String followerId, String followingId) async {
    return await repository.checkFollowStatus(followerId, followingId);
  }
}

class ProfileToggleWatchlistUseCase {
  final ProfileRepository repository;
  ProfileToggleWatchlistUseCase(this.repository);

  Future<void> call(String userId, String stockSymbol) async {
    return await repository.toggleWatchlist(userId, stockSymbol);
  }
}

class GetUserWatchlistUseCase {
  final ProfileRepository repository;
  GetUserWatchlistUseCase(this.repository);

  Future<List<String>> call(String userId) async {
    return await repository.getUserWatchlist(userId);
  }
}
