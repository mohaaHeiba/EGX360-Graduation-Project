import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/usecase/get_saved_posts_usecase.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedPostsController extends GetxController {
  final GetSavedPostsUseCase getSavedPostsUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final TogglePostVoteUseCase togglePostVoteUseCase;

  SavedPostsController({
    required this.getSavedPostsUseCase,
    required this.toggleBookmarkUseCase,
    required this.togglePostVoteUseCase,
  });

  final RxList<PostEntity> savedPosts = <PostEntity>[].obs;
  final RxBool isPostsLoading = false.obs;

  String get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchSavedPosts();
  }

  Future<void> fetchSavedPosts() async {
    if (currentUserId.isEmpty) return;
    try {
      isPostsLoading.value = true;
      final result = await getSavedPostsUseCase(currentUserId);
      savedPosts.assignAll(result);
    } catch (e) {
      customSnackbar(
        title: S.current.error_label,
        message: S.current.failed_to_load_data,
        color: AppColors.error,
      );
    } finally {
      isPostsLoading.value = false;
    }
  }

  Future<void> toggleLike(int index) async {
    final post = savedPosts[index];
    final oldPost = post;

    final newLikedStatus = !post.isLiked;
    final int newLikesCount = newLikedStatus
        ? post.likesCount + 1
        : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    savedPosts[index] = post.copyWith(
      isLiked: newLikedStatus,
      likesCount: newLikesCount,
    );
    savedPosts.refresh();

    try {
      final int? voteType = newLikedStatus ? 1 : null;
      await togglePostVoteUseCase(currentUserId, post.id, voteType);
    } catch (e) {
      savedPosts[index] = oldPost;
      savedPosts.refresh();
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_like_failed,
        color: AppColors.error,
      );
    }
  }

  Future<void> toggleBookmark(int index) async {
    final post = savedPosts[index];

    // Optimistic update: remove from list immediately since we are in "Saved Posts"
    savedPosts.removeAt(index);

    try {
      await toggleBookmarkUseCase(currentUserId, post.id);
    } catch (e) {
      // Revert if failed
      savedPosts.insert(index, post);
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_save_failed,
        color: AppColors.error,
      );
    }
  }
}
