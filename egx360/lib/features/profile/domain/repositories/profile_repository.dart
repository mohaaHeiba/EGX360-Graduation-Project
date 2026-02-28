import 'dart:io';

import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/post_details/domain/entity/comment_entity.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/entity/profile_stats.dart';

abstract class ProfileRepository {
  Future<ProfileStats> getProfileStats(String userId);
  Future<List<PostEntity>> getUserPosts(String userId);
  Future<List<PostEntity>> getViewedUserPosts(String userId);
  Future<int> createPost({
    required String userId,
    String? content,
    File? imageFile,

    String? sentiment,
    List<String>? cashtags,
  });

  Future<void> togglePostVote(String userId, int postId, int? voteType);

  Future<List<CommentEntity>> getPostComments(int postId);

  Future<void> addComment({
    required String userId,
    required int postId,
    required String content,
    int? parentId,
  });

  Future<void> toggleCommentVote(String userId, int commentId, int? voteType);

  Future<void> toggleFollow(String followerId, String followingId);

  Future<void> toggleBookmark(String userId, int postId);

  Future<bool> checkFollowStatus(String followerId, String followingId);

  Future<void> toggleWatchlist(String userId, String stockSymbol);

  Future<List<String>> getUserWatchlist(String userId);

  Future<AuthEntity> getUserProfile(String userId);

  Future<List<AuthEntity>> getFollowers(String userId);
  Future<List<AuthEntity>> getFollowing(String userId);
  Future<PostEntity> getPostById(int postId);
  Future<CommentEntity> getCommentById(int commentId);
  Future<List<PostEntity>> getSavedPosts(String userId);
}
