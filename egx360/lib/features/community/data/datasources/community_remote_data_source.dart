import 'package:egx/core/errors/app_exception.dart';
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
      // Use hardcoded data as per plan since 'stocks' table doesn't exist

      final response = await _supabaseClient.from('stocks').select();

      print("Stock Fetch Error: ${response}");

      return (response as List).map((e) => StockModel.fromJson(e)).toList();
    } catch (e) {
      print("Stock Fetch Error: $e");
      throw DatabaseAppException('Failed to fetch stocks');
    }
  }
}
