import 'dart:async';
import 'package:flutter/material.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/auth/data/model/auth_model.dart';
import 'package:egx/features/community/domain/usecase/get_all_posts_usecase.dart';
import 'package:egx/features/community/domain/usecase/get_stocks_usecase.dart';
import 'package:egx/features/community/domain/entity/stock_entity.dart';
import 'package:egx/features/community/domain/repositories/community_repository.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityController extends GetxController {
  final GetAllPostsUseCase getAllPostsUseCase = Get.find();
  final TogglePostVoteUseCase togglePostVoteUseCase = Get.find();
  final ToggleBookmarkUseCase toggleBookmarkUseCase = Get.find();
  final GetStocksUseCase getStocksUseCase = Get.find();
  final CommunityRepository communityRepository = Get.find();

  var posts = <PostEntity>[].obs;
  var stocks = <StockEntity>[].obs;
  var isLoading = true.obs;
  var isPaginationLoading = false.obs;
  var isMoreDataAvailable = true.obs;

  // ── Trending Topics ──
  var trendingTopics = <Map<String, dynamic>>[].obs;
  var isLoadingTrending = false.obs;

  // ── Who to Follow ──
  var suggestedUsers = <AuthModel>[].obs;
  var isLoadingSuggested = false.obs;
  var followedUserIds = <String>{}.obs;
  var togglingFollowIds = <String>{}.obs;
  int _page = 0;
  final int _limit = 10;
  final ScrollController scrollController = ScrollController();

  String get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  final Rx<StockEntity?> selectedStock = Rx<StockEntity?>(null);

  // Debounce handling
  Timer? _voteDebounceTimer;
  // Map to store original state of posts being modified (key: post ID)
  final Map<int, PostEntity> _originalPostStates = {};

  // Removed filteredPosts getter as we now filter on server side
  // Use posts list directly in UI

  void toggleStockFilter(StockEntity stock) {
    print("Toggling filter: ${stock.symbol}");
    if (selectedStock.value?.symbol == stock.symbol) {
      print("Clearing filter");
      selectedStock.value = null;
    } else {
      print("Setting filter to ${stock.symbol}");
      selectedStock.value = stock;
    }
    // Refresh posts with new filter
    fetchPosts(refresh: true);
  }

  void setAllFilter() {
    if (selectedStock.value != null) {
      selectedStock.value = null;
      selectedStock.refresh();
      fetchPosts(refresh: true);
    }
  }

  void fetchAll(final fetchAll) {
    if (fetchAll == null) {
      selectedStock.value = null;
    }
    // Refresh posts with new filter
    fetchPosts(refresh: true);
  }

  @override
  void onClose() {
    _voteDebounceTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    fetchStocks();
    fetchTrendingTopics();
    fetchSuggestedUsers();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchPosts();
    }
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    print("fetchPosts called. refresh: $refresh");
    if (refresh) {
      _page = 0;
      isMoreDataAvailable.value = true;
      posts.clear();
      isLoading.value = true;
      print("State reset. posts cleared. isLoading: true");
    } else {
      if (!isMoreDataAvailable.value || isPaginationLoading.value) return;
      isPaginationLoading.value = true;
    }

    try {
      final offset = _page * _limit;
      final category = selectedStock.value?.symbol;
      final result = await getAllPostsUseCase.call(
        limit: _limit,
        offset: offset,
        category: category,
      );

      if (result.length < _limit) {
        isMoreDataAvailable.value = false;
      }

      if (refresh) {
        posts.assignAll(result);
      } else {
        posts.addAll(result);
      }

      _page++;
    } catch (e) {
      print("Error fetching community posts: $e");
      customSnackbar(
        title: S.current.error_label,
        message: S.current.failed_to_load_data,
        color: AppColors.candleRed,
      );
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  Future<void> fetchStocks() async {
    try {
      final result = await getStocksUseCase.call();
      stocks.assignAll(result);
    } catch (e) {
      print("Error fetching stocks: $e");
      // Fallback to hardcoded data if fetch fails?
      // For now just log error
    }
  }

  Future<void> refreshPosts() async {
    await fetchPosts(refresh: true);
    await fetchStocks();
    await fetchTrendingTopics();
    await fetchSuggestedUsers();
  }

  // ── Trending Topics ──

  Future<void> fetchTrendingTopics() async {
    if (isLoadingTrending.value) return;
    isLoadingTrending.value = true;
    try {
      final result = await communityRepository.getTrendingTopics(limit: 5);
      trendingTopics.assignAll(result);
    } catch (e) {
      print('Error fetching trending topics: $e');
    } finally {
      isLoadingTrending.value = false;
    }
  }

  // ── Who to Follow ──

  Future<void> fetchSuggestedUsers() async {
    if (currentUserId.isEmpty || isLoadingSuggested.value) return;
    isLoadingSuggested.value = true;
    try {
      final users = await communityRepository.getSuggestedUsers(
        currentUserId,
        limit: 5,
      );
      suggestedUsers.assignAll(users);

      // Load current following IDs for button state
      final resp = await Supabase.instance.client
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUserId);
      final ids = (resp as List)
          .map((e) => e['following_id'] as String)
          .toSet();
      followedUserIds.clear();
      followedUserIds.addAll(ids);
    } catch (e) {
      print('Error fetching suggested users: $e');
    } finally {
      isLoadingSuggested.value = false;
    }
  }

  Future<void> toggleFollowUser(String userId) async {
    if (currentUserId.isEmpty || togglingFollowIds.contains(userId)) return;
    togglingFollowIds.add(userId);

    final wasFollowing = followedUserIds.contains(userId);

    // Optimistic update
    if (wasFollowing) {
      followedUserIds.remove(userId);
    } else {
      followedUserIds.add(userId);
    }
    followedUserIds.refresh();

    try {
      final dataSource = Get.find<ProfileRemoteDataSource>();
      await dataSource.toggleFollow(
        followerId: currentUserId,
        followingId: userId,
      );
      // After successfully following, remove from suggestions
      if (!wasFollowing) {
        suggestedUsers.removeWhere((u) => u.id == userId);
      }
    } catch (e) {
      // Revert
      if (wasFollowing) {
        followedUserIds.add(userId);
      } else {
        followedUserIds.remove(userId);
      }
      followedUserIds.refresh();
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_like_failed,
        color: AppColors.candleRed,
      );
    } finally {
      togglingFollowIds.remove(userId);
    }
  }

  Future<void> toggleLike(int index) async {
    if (currentUserId.isEmpty) {
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_login_to_like,
        color: AppColors.candleRed,
      );
      return;
    }
    // We need to find the actual post in the main list
    // index here comes from the filtered list in the UI
    // Since we are doing server-side filtering, posts list IS the filtered list
    final post = posts[index];

    // 1. Cancel existing timer
    if (_voteDebounceTimer?.isActive ?? false) {
      _voteDebounceTimer!.cancel();
    }

    // 2. Save original state if not already saved for this sequence
    if (!_originalPostStates.containsKey(post.id)) {
      _originalPostStates[post.id] = post;
    }

    // 3. Optimistic Update
    final bool newLikedStatus = !post.isLiked;
    final int newLikesCount = newLikedStatus
        ? post.likesCount + 1
        : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    final newPost = post.copyWith(
      isLiked: newLikedStatus,
      likesCount: newLikesCount,
    );

    posts[index] = newPost;
    posts.refresh();

    // 4. Start Debounce Timer
    _voteDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        // If new status is Liked, voteType is 1. If Unliked, voteType is null (remove vote).
        final int? voteType = newPost.isLiked ? 1 : null;
        await togglePostVoteUseCase.call(currentUserId, newPost.id, voteType);

        // Success, clear backup for this post
        _originalPostStates.remove(newPost.id);
      } catch (e) {
        // Revert to original state on error
        if (_originalPostStates.containsKey(newPost.id)) {
          final original = _originalPostStates[newPost.id]!;
          // Find index again as it might have changed (though unlikely in this controller structure)
          final revertIndex = posts.indexWhere((p) => p.id == original.id);
          if (revertIndex != -1) {
            posts[revertIndex] = original;
            posts.refresh();
          }
          _originalPostStates.remove(newPost.id);
        }
        customSnackbar(
          title: S.current.error_label,
          message: S.current.community_like_failed,
          color: AppColors.candleRed,
        );
      }
    });
  }

  Future<void> toggleBookmark(int index) async {
    if (currentUserId.isEmpty) {
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_login_to_bookmark,
        color: AppColors.candleRed,
      );
      return;
    }
    final post = posts[index];
    final oldPost = post;
    final newPost = post.copyWith(isBookmarked: !post.isBookmarked);

    posts[index] = newPost;
    posts.refresh();

    try {
      await toggleBookmarkUseCase.call(currentUserId, post.id);
    } catch (e) {
      posts[index] = oldPost;
      posts.refresh();
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_save_failed,
        color: AppColors.candleRed,
      );
    }
  }

  // Selected Post for Desktop View
  final Rx<PostEntity?> selectedPost = Rx<PostEntity?>(null);

  void selectPost(PostEntity post) {
    selectedPost.value = post;
  }

  void clearSelectedPost() {
    selectedPost.value = null;
  }

  void navigateToPostDetails(PostEntity post) {
    if (Get.width >= 800) {
      // Desktop: Select post to show in right/center panel
      selectPost(post);
    } else {
      // Mobile: Navigate to new page
      Get.toNamed(AppPages.showDetailsPage, arguments: post);
    }
  }
}
