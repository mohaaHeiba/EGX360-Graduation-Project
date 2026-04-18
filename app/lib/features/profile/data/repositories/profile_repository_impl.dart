import 'dart:io';

import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/core/data/entities/post_local_model.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/post_details/domain/entity/comment_entity.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/entity/profile_stats.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final InitLocalData localData;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localData,
  });

  @override
  Future<List<PostEntity>> getUserPosts(String userId) async {
    try {
      final remotePosts = await remoteDataSource.getUserPosts(userId);
      print("✅ Repo: Fetched ${remotePosts.length} posts from Supabase");

      // Only cache posts for the current user
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null && userId == currentUserId) {
        final localPosts = remotePosts
            .map((e) => PostLocalModel.fromEntity(e))
            .toList();

        await localData.saveUserPosts(userId, localPosts);
        print("✅ Repo: Saved posts to Local DB");
      } else {
        print("ℹ️ Repo: Skipped saving posts to Local DB (Not current user)");
      }

      return remotePosts;
    } catch (e) {
      print("⚠️ Repo Error: $e");

      // Only fetch from local DB if it's the current user (or if we decide to allow reading cached data for others, but we just stopped writing it)
      // If we stopped writing, reading might return old data or empty.
      // For now, let's allow reading if it exists, but since we don't write, it won't grow.
      // Actually, if the user explicitly doesn't want connection, maybe we shouldn't even read?
      // But the error fallback is useful.
      // Let's keep reading as fallback, but since we don't write, it's fine.

      final localDataPosts = await localData.getUserPosts(userId);

      if (localDataPosts.isNotEmpty) {
        return localDataPosts.map((e) => e.toEntity()).toList();
      }
      throw e;
    }
  }

  @override
  Future<List<PostEntity>> getViewedUserPosts(String userId) async {
    // Pure remote call, no local DB interaction
    try {
      final remotePosts = await remoteDataSource.getUserPosts(userId);
      print(
        "✅ Repo: Fetched ${remotePosts.length} viewed user posts from Supabase",
      );
      return remotePosts;
    } catch (e) {
      print("⚠️ Repo Error (Viewed User): $e");
      rethrow;
    }
  }

  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    return await remoteDataSource.getStats(userId);
  }

  // 🔥 التعديل هنا: استقبال وتمرير البيانات الجديدة
  @override
  Future<int> createPost({
    required String userId,
    String? content,
    File? imageFile,
    String? sentiment, // ✅
    List<String>? cashtags, // ✅
  }) => remoteDataSource.createPost(
    userId: userId,
    content: content,
    imageFile: imageFile,
    sentiment: sentiment, // ✅
    cashtags: cashtags, // ✅
  );

  @override
  Future<void> togglePostVote(String userId, int postId, int? voteType) =>
      remoteDataSource.togglePostVote(
        userId: userId,
        postId: postId,
        voteType: voteType,
      );

  @override
  Future<List<CommentEntity>> getPostComments(int postId) =>
      remoteDataSource.getPostComments(postId);

  @override
  Future<void> addComment({
    required String userId,
    required int postId,
    required String content,
    int? parentId,
  }) => remoteDataSource.addComment(
    userId: userId,
    postId: postId,
    content: content,
    parentId: parentId,
  );

  @override
  Future<void> toggleCommentVote(String userId, int commentId, int? voteType) =>
      remoteDataSource.toggleCommentVote(
        userId: userId,
        commentId: commentId,
        voteType: voteType,
      );

  @override
  Future<void> toggleFollow(String followerId, String followingId) =>
      remoteDataSource.toggleFollow(
        followerId: followerId,
        followingId: followingId,
      );

  @override
  Future<void> toggleBookmark(String userId, int postId) =>
      remoteDataSource.toggleBookmark(userId: userId, postId: postId);

  @override
  Future<bool> checkFollowStatus(String followerId, String followingId) =>
      remoteDataSource.checkFollowStatus(
        followerId: followerId,
        followingId: followingId,
      );

  @override
  Future<void> toggleWatchlist(String userId, String stockSymbol) =>
      remoteDataSource.toggleWatchlist(
        userId: userId,
        stockSymbol: stockSymbol,
      );

  @override
  Future<List<String>> getUserWatchlist(String userId) =>
      remoteDataSource.getUserWatchlist(userId);

  @override
  Future<AuthEntity> getUserProfile(String userId) =>
      remoteDataSource.getUserProfile(userId);

  @override
  Future<List<AuthEntity>> getFollowers(String userId) =>
      remoteDataSource.getFollowers(userId);

  @override
  Future<List<AuthEntity>> getFollowing(String userId) =>
      remoteDataSource.getFollowing(userId);

  @override
  Future<PostEntity> getPostById(int postId) =>
      remoteDataSource.getPostById(postId);

  @override
  Future<CommentEntity> getCommentById(int commentId) =>
      remoteDataSource.getCommentById(commentId);

  @override
  Future<List<PostEntity>> getSavedPosts(String userId) async {
    try {
      final remotePosts = await remoteDataSource.getSavedPosts(userId);
      return remotePosts;
    } catch (e) {
      print("Repo Error (Saved Posts): $e");
      rethrow;
    }
  }
}
