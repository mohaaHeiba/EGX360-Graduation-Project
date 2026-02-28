import 'package:egx/core/data/entities/post_local_model.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitLocalData extends GetxService {
  final _box = GetStorage();

  final Rx<AuthEntity?> currentUser = Rx<AuthEntity?>(null);
  final RxList<PostEntity> userPosts = <PostEntity>[].obs;

  static const String _authKey = 'auth_data';
  static const String _postsKey = 'posts_cache';

  Future<InitLocalData> initDatabase() async {
    // Load current user
    final authData = _box.read(_authKey);
    if (authData != null) {
      currentUser.value = AuthEntity.fromJson(authData);
      print("User found: ${currentUser.value!.name}");

      // Load user posts
      final postsData = _box.read<List>('$_postsKey/${currentUser.value!.id}');
      if (postsData != null) {
        final localPosts = postsData
            .map((e) => PostLocalModel.fromJson(e))
            .toList();
        userPosts.assignAll(localPosts.map((e) => e.toEntity()).toList());
        print("Loaded ${userPosts.length} cached posts.");
      }
    } else {
      print("No user found in local database.");
    }

    return this;
  }

  // Auth Methods
  Future<void> saveAuthData(AuthEntity authEntity) async {
    await _box.write(_authKey, authEntity.toJson());
    currentUser.value = authEntity;
  }

  Future<AuthEntity?> getAuthData() async {
    final data = _box.read(_authKey);
    return data != null ? AuthEntity.fromJson(data) : null;
  }

  Future<void> clearAuthData() async {
    await _box.remove(_authKey);
    currentUser.value = null;
  }

  // Posts Methods
  Future<void> saveUserPosts(String userId, List<PostLocalModel> posts) async {
    final postsJson = posts.map((e) => e.toJson()).toList();
    await _box.write('$_postsKey/$userId', postsJson);
  }

  Future<List<PostLocalModel>> getUserPosts(String userId) async {
    final data = _box.read<List>('$_postsKey/$userId');
    if (data != null) {
      return data.map((e) => PostLocalModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> clearUserPosts(String userId) async {
    await _box.remove('$_postsKey/$userId');
  }
}
