import 'package:egx/core/errors/app_exception.dart';
import 'package:egx/features/auth/data/model/auth_model.dart';
import 'package:egx/features/community/data/model/stock_model.dart';
import 'package:egx/features/profile/data/model/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostModel>> getAllPosts({
    required int limit,
    required int offset,
    String? category,
  });
  Future<List<StockModel>> getStocks();

  /// Returns top [limit] trending symbols based on post count in the last 7 days.
  /// Each entry: {'symbol': String, 'postCount': int}
  Future<List<Map<String, dynamic>>> getTrendingTopics({int limit = 5});

  /// Returns [limit] users from `profiles` excluding the current user and
  /// anyone the current user already follows.
  Future<List<AuthModel>> getSuggestedUsers(
    String currentUserId, {
    int limit = 5,
  });
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final SupabaseClient _supabaseClient;
  CommunityRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<PostModel>> getAllPosts({
    required int limit,
    required int offset,
    String? category,
  }) async {
    try {
      print(
        "Fetching posts with category: $category, limit: $limit, offset: $offset",
      );
      // Use the same RPC function but with null target_user_id to get all posts
      final response = await _supabaseClient.rpc(
        'get_posts_with_status',
        params: {
          'viewer_id': _supabaseClient.auth.currentUser?.id,
          'target_user_id': null, // null means get all posts
          'limit_val': limit,
          'offset_val': offset,
          'category_filter': category,
        },
      );

      return (response as List).map((e) => PostModel.fromMap(e)).toList();
    } catch (e) {
      print("Community RPC Error: $e");
      throw DatabaseAppException('Failed to fetch community posts');
    }
  }

  @override
  Future<List<StockModel>> getStocks() async {
    try {
      final response = await _supabaseClient.from('stocks').select();
      return (response as List).map((e) => StockModel.fromJson(e)).toList();
    } catch (e) {
      print("Stock Fetch Error: $e");
      throw DatabaseAppException('Failed to fetch stocks');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingTopics({int limit = 5}) async {
    try {
      // Fetch posts from the last 7 days that have cashtags
      final since = DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String();
      final response = await _supabaseClient
          .from('posts')
          .select('cashtags')
          .not('cashtags', 'is', null)
          .gte('created_at', since);

      // Count occurrences of each symbol across all cashtags arrays
      final Map<String, int> counts = {};
      for (final row in response as List) {
        final tags = row['cashtags'];
        if (tags == null) continue;
        final List<dynamic> tagList = tags is List ? tags : [];
        for (final tag in tagList) {
          final symbol = tag.toString().toUpperCase();
          if (symbol.isNotEmpty) {
            counts[symbol] = (counts[symbol] ?? 0) + 1;
          }
        }
      }

      // Sort by count descending, take top N
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted
          .take(limit)
          .map((e) => {'symbol': e.key, 'postCount': e.value})
          .toList();
    } catch (e) {
      print("Trending Topics Error: $e");
      return [];
    }
  }

  @override
  Future<List<AuthModel>> getSuggestedUsers(
    String currentUserId, {
    int limit = 5,
  }) async {
    try {
      // Get IDs of users the current user already follows
      final followingResp = await _supabaseClient
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUserId);

      final followingIds = (followingResp as List)
          .map((e) => e['following_id'] as String)
          .toList();

      // Exclude self + already-followed users
      final excludeIds = [...followingIds, currentUserId];

      // Fetch random profiles not in exclude list
      var query = _supabaseClient
          .from('profiles')
          .select()
          .not('id', 'in', excludeIds)
          .limit(limit);

      final response = await query;
      return (response as List).map((e) => AuthModel.fromMap(e)).toList();
    } catch (e) {
      print("Suggested Users Error: $e");
      return [];
    }
  }
}
