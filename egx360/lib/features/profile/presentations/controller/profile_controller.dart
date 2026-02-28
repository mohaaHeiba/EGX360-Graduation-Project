import 'dart:async';
import 'dart:io';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/core/services/notification_sender_service.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/generated/l10n.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egx/core/errors/app_exception.dart';
import 'package:egx/core/services/media_service.dart';
import 'package:egx/core/data/init_local_data.dart';

import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/community/domain/entity/stock_entity.dart';
import 'package:egx/features/community/domain/usecase/get_stocks_usecase.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/entity/profile_stats.dart';
import 'package:egx/features/profile/domain/usecase/create_post_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_profile_stats_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_user_posts_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_user_profile_usecase.dart';
import 'package:egx/features/profile/domain/usecase/get_viewed_user_posts_usecase.dart';

class ProfileController extends GetxController {
  final getProfileStatsUseCase = Get.find<GetProfileStatsUseCase>();
  final getUserPostsUseCase = Get.find<GetUserPostsUseCase>();
  final getViewedUserPostsUseCase = Get.find<GetViewedUserPostsUseCase>();
  final getUserProfileUseCase = Get.find<GetUserProfileUseCase>();
  final createPostUseCase = Get.find<CreatePostUseCase>();
  final toggleFollowUseCase = Get.find<ToggleFollowUseCase>();
  final checkFollowStatusUseCase = Get.find<CheckFollowStatusUseCase>();

  final InitLocalData _localData = Get.find<InitLocalData>();
  final MediaService _mediaService = MediaService();

  var isLoading = false.obs;
  var isPostsLoading = false.obs;
  var isPostValid = false.obs;

  var isFollowing = false.obs;
  var isCheckingFollow = false.obs;

  var selectedSentiment = Rx<String?>(null);
  var isCreatePostExpanded = false.obs;
  var showHeadlineField = false.obs;

  Rx<AuthEntity?> userProfile = Rx<AuthEntity?>(null);
  Rx<ProfileStats?> userStats = Rx<ProfileStats?>(null);
  RxList<PostEntity> userPosts =
      <PostEntity>[].obs; // Current User Posts (Cached)

  // Debounce handling
  Timer? _voteDebounceTimer;
  // Map to store original state of posts being modified (key: post ID)
  final Map<int, PostEntity> _originalPostStates = {};

  File? pickedImage;
  late TextEditingController postTextController;
  late TextEditingController headlineTextController;

  String get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  // --- 4. Lifecycle Methods ---

  @override
  void onInit() {
    super.onInit();
    postTextController = TextEditingController();
    headlineTextController = TextEditingController();

    postTextController.addListener(_validatePost);
    headlineTextController.addListener(_validatePost);

    loadCachedData();
    loadFullData();
    fetchStocks();
  }

  @override
  void onClose() {
    _voteDebounceTimer?.cancel();
    postTextController.dispose();
    headlineTextController.dispose();
    super.onClose();
  }

  final ToggleBookmarkUseCase toggleBookmarkUseCase =
      Get.find<ToggleBookmarkUseCase>();
  final TogglePostVoteUseCase togglePostVoteUseCase =
      Get.find<TogglePostVoteUseCase>();

  Future<void> toggleBookmark(int index) async {
    // 1. Select the correct list
    final targetList = userPosts;

    final post = targetList[index];
    final oldPost = post;

    targetList[index] = post.copyWith(isBookmarked: !post.isBookmarked);
    targetList.refresh();

    try {
      await toggleBookmarkUseCase.call(currentUserId, post.id);

      _localData.userPosts.assignAll(userPosts);
    } catch (e) {
      targetList[index] = oldPost;
      targetList.refresh();
      customSnackbar(
        title: S.current.error_label,
        message: S.current.community_save_failed,
        color: AppColors.error.withOpacity(0.5),
      );
    }
  }

  // ...

  Future<void> toggleLike(int index) async {
    // 1. Select the correct list
    final targetList = userPosts;

    // 2. Cancel existing timer
    if (_voteDebounceTimer?.isActive ?? false) {
      _voteDebounceTimer!.cancel();
    }

    final post = targetList[index];

    // 3. Save original state if not already saved for this sequence
    if (!_originalPostStates.containsKey(post.id)) {
      _originalPostStates[post.id] = post;
    }

    // 4. Optimistic Update
    final bool newLikedStatus = !post.isLiked;
    final int newLikesCount = newLikedStatus
        ? post.likesCount + 1
        : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    final newPost = post.copyWith(
      isLiked: newLikedStatus,
      likesCount: newLikesCount,
    );

    targetList[index] = newPost;
    targetList.refresh();

    // 5. Start Debounce Timer
    _voteDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        // If new status is Liked, voteType is 1. If Unliked, voteType is null (remove vote).
        final int? voteType = newPost.isLiked ? 1 : null;
        await togglePostVoteUseCase.call(currentUserId, newPost.id, voteType);

        //  (Only for current user posts)
        _localData.userPosts.assignAll(userPosts);

        // Success, clear backup for this post
        _originalPostStates.remove(newPost.id);
      } catch (e) {
        print("Like failed: $e");
        // Revert to original state on error
        if (_originalPostStates.containsKey(newPost.id)) {
          final original = _originalPostStates[newPost.id]!;
          final revertIndex = targetList.indexWhere((p) => p.id == original.id);
          if (revertIndex != -1) {
            targetList[revertIndex] = original;
            targetList.refresh();
          }
          _originalPostStates.remove(newPost.id);
        }

        customSnackbar(
          title: S.current.error_label,
          message: S.current.error_network,
          color: AppColors.error.withOpacity(0.5),
        );
      }
    });
  }

  // --- 5. Logic & Validation ---

  // --- Autocomplete ---
  final GetStocksUseCase getStocksUseCase = Get.find<GetStocksUseCase>();
  var stocks = <StockEntity>[].obs;
  var filteredStocks = <StockEntity>[].obs;
  var selectedStocks = <StockEntity>[].obs;
  var showAutocomplete = false.obs;
  String? currentMatch;

  void _validatePost() {
    bool hasText = postTextController.text.trim().isNotEmpty;
    bool hasHeadline = headlineTextController.text.trim().isNotEmpty;
    bool hasImage = pickedImage != null;
    isPostValid.value = (hasText || hasHeadline) || hasImage;
    _checkForCashtag();
  }

  void _checkForCashtag() {
    final text = postTextController.text;
    final selection = postTextController.selection;

    if (!selection.isValid || selection.start == -1) {
      showAutocomplete.value = false;
      return;
    }

    final cursorPosition = selection.start;
    final textBeforeCursor = text.substring(0, cursorPosition);

    // Find the last '$' before cursor
    final lastDollarIndex = textBeforeCursor.lastIndexOf('\$');

    if (lastDollarIndex != -1) {
      // Check if there's a space after the dollar (invalidating the tag)
      // or if the dollar is part of a valid tag being typed
      final query = textBeforeCursor.substring(lastDollarIndex + 1);

      // Ensure no spaces in the query
      if (!query.contains(' ')) {
        currentMatch = query;
        _filterStocks(query);
        showAutocomplete.value = filteredStocks.isNotEmpty;
        return;
      }
    }

    showAutocomplete.value = false;
  }

  void _filterStocks(String query) {
    if (query.isEmpty) {
      filteredStocks.assignAll(stocks);
    } else {
      filteredStocks.assignAll(
        stocks.where((stock) {
          return stock.symbol.toLowerCase().contains(query.toLowerCase()) ||
              stock.companyNameEn.toLowerCase().contains(query.toLowerCase()) ||
              (stock.companyNameAr.toLowerCase().contains(query.toLowerCase()));
        }).toList(),
      );
    }
  }

  void selectStock(StockEntity stock) {
    final text = postTextController.text;
    final selection = postTextController.selection;
    final cursorPosition = selection.start;
    final textBeforeCursor = text.substring(0, cursorPosition);
    final lastDollarIndex = textBeforeCursor.lastIndexOf('\$');

    if (lastDollarIndex != -1) {
      // Remove the typed query (e.g., "$TM")
      final newText = text.replaceRange(lastDollarIndex, cursorPosition, "");

      postTextController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: lastDollarIndex),
      );

      // Add to selected stocks if not already present
      if (!selectedStocks.contains(stock)) {
        selectedStocks.add(stock);
      }

      showAutocomplete.value = false;
    }
  }

  void removeStock(StockEntity stock) {
    selectedStocks.remove(stock);
  }

  void setSentiment(String value) {
    if (selectedSentiment.value == value) {
      selectedSentiment.value = null;
    } else {
      selectedSentiment.value = value;
    }
  }

  void addStockSymbol() {
    if (showAutocomplete.value) {
      showAutocomplete.value = false;

      // Remove the '$' if it exists before the cursor
      final text = postTextController.text;
      final selection = postTextController.selection;
      if (selection.isValid && selection.start > 0) {
        final cursorPosition = selection.start;
        if (text[cursorPosition - 1] == '\$') {
          final newText = text.replaceRange(
            cursorPosition - 1,
            cursorPosition,
            "",
          );
          postTextController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorPosition - 1),
          );
        }
      }
      return;
    }

    final text = postTextController.text;
    final selection = postTextController.selection;

    int start = selection.isValid ? selection.start : text.length;

    final newText = text.replaceRange(start, start, "\$");

    postTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
    // This will trigger listener and show autocomplete with all stocks
  }

  List<String> _extractCashtags(String text) {
    // Extract manual cashtags if any left in text
    final RegExp regex = RegExp(r'\$[a-zA-Z0-9]+');
    final Iterable<Match> matches = regex.allMatches(text);
    final manualTags = matches.map((m) => m.group(0)!).toList();

    final chipTags = selectedStocks.map((s) => "\$${s.symbol}").toList();

    // ignore: prefer_collection_literals
    return [...manualTags, ...chipTags].toSet().toList(); // Unique tags
  }

  // --- 6. Data Loading ---

  void loadCachedData() {
    if (_localData.currentUser.value != null) {
      userProfile.value = _localData.currentUser.value;
    }
    if (_localData.userPosts.isNotEmpty) {
      userPosts.assignAll(_localData.userPosts);
    }
  }

  Future<void> loadFullData() async {
    await Future.wait([fetchStats(), fetchPosts()]);
  }

  Future<void> fetchStats({String? userId}) async {
    final targetId = userId ?? currentUserId;
    if (targetId.isEmpty) return;

    try {
      // Fetch stats for the viewed user (or current user if viewing own profile)
      final result = await getProfileStatsUseCase(targetId);
      userStats.value = result;
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  // Fetch posts for the CURRENT user (with caching)
  // Fetch posts for the CURRENT user (with caching)
  Future<void> fetchPosts() async {
    if (currentUserId.isEmpty) return;
    try {
      isPostsLoading.value = true;
      final result = await getUserPostsUseCase(currentUserId);
      print("✅ My Posts Found: ${result.length}");
      userPosts.assignAll(result);
      _localData.userPosts.assignAll(result);
    } catch (e) {
      print("❌ Error fetching my posts: $e");
    } finally {
      isPostsLoading.value = false;
    }
  }

  Future<void> fetchViewedProfile(String userId) async {
    try {
      final result = await getUserProfileUseCase(userId);
      userProfile.value = result;
      await checkFollowStatus(userId);
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> checkFollowStatus(String targetUserId) async {
    if (currentUserId.isEmpty || targetUserId == currentUserId) return;
    try {
      isCheckingFollow.value = true;
      final result = await checkFollowStatusUseCase(
        currentUserId,
        targetUserId,
      );
      isFollowing.value = result;
    } catch (e) {
      print("Error checking follow status: $e");
    } finally {
      isCheckingFollow.value = false;
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    if (currentUserId.isEmpty) return;
    try {
      isCheckingFollow.value = true;
      final wasFollowing = isFollowing.value;
      await toggleFollowUseCase(currentUserId, targetUserId);
      isFollowing.value = !isFollowing.value;

      // 🔔 Send notification if we just followed someone
      if (!wasFollowing && isFollowing.value) {
        final userName =
            Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
            'Someone';
        NotificationSenderService.notifyNewFollow(
          followedUserId: targetUserId,
          followerName: userName,
          followerId: currentUserId,
        );
      }

      // Update stats locally if possible, or refetch
      if (userStats.value != null) {
        // This logic depends on whose stats we are viewing.
        // If viewing other user, their followers count changes.
        // If viewing self (not possible here usually), following count changes.
        // For simplicity, just refetch stats.
        fetchStats(userId: targetUserId);
      }

      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().fetchStats();
      }
    } catch (e) {
      print("Error toggling follow: $e");
      customSnackbar(
        title: S.current.error_label,
        message: S.current.profile_failed_to_follow,
        color: AppColors.error,
      );
    } finally {
      isCheckingFollow.value = false;
    }
  }

  Future<void> fetchStocks() async {
    try {
      final result = await getStocksUseCase.call();
      stocks.assignAll(result);
    } catch (e) {
      print("Error fetching stocks for autocomplete: $e");
    }
  }

  // --- 7. User Actions ---

  Future<void> pickImage() async {
    final XFile? image = await _mediaService.pickFromGalleryAsWebP();
    if (image != null) {
      pickedImage = File(image.path);
      _validatePost();
      update();
    }
  }

  void clearImage() {
    pickedImage = null;
    _validatePost();
    update();
  }

  Future<void> createPost({bool goBack = true}) async {
    if (currentUserId.isEmpty) {
      customSnackbar(
        title: S.current.error_label,
        message: S.current.profile_login_to_post,
        color: AppColors.error,
      );
      return;
    }
    final String body = postTextController.text;
    final String headline = headlineTextController.text;

    // Concatenate headline and body with the separator
    final String content = headline.isNotEmpty
        ? "$headline---splite---$body"
        : body;

    if (!isPostValid.value) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      List<String> cashtags = _extractCashtags(content);

      final newPostId = await createPostUseCase(
        userId: currentUserId,
        content: content,
        imageFile: pickedImage,
        sentiment: selectedSentiment.value,
        cashtags: cashtags,
      );

      // 🔔 Notify all followers about new post
      final userName =
          Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
          'User';
      NotificationSenderService.notifyAllFollowers(
        currentUserId: currentUserId,
        currentUserName: userName,
        postId: newPostId,
        postPreview: content,
      );

      Get.back(); // Close loading dialog

      if (goBack) {
        Get.back(); // Close page if requested
      }

      postTextController.clear();
      headlineTextController.clear();
      selectedSentiment.value = null;
      clearImage();

      customSnackbar(
        title: S.current.success_label,
        message: S.current.profile_idea_published,
        color: Colors.green,
      );

      fetchStats();
      fetchPosts();

      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().fetchStats();
      }
    } catch (e) {
      Get.back();
      print("💥 SUPABASE REAL ERROR: $e");

      String errorMessage = "Failed to create post";
      if (e is DatabaseAppException) {
        errorMessage = e.message;
      }

      customSnackbar(
        title: S.current.error_label,
        message: errorMessage,
        color: Colors.red,
      );
    }
  }
}
