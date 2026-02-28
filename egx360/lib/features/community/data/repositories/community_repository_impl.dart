import 'package:egx/features/community/data/datasources/community_remote_data_source.dart';
import 'package:egx/features/community/domain/entity/stock_entity.dart';
import 'package:egx/features/community/domain/repositories/community_repository.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getAllPosts({
    required int limit,
    required int offset,
    String? category,
  }) async {
    try {
      final remotePosts = await remoteDataSource.getAllPosts(
        limit: limit,
        offset: offset,
        category: category,
      );
      return remotePosts;
    } catch (e) {
      print("⚠️ Community Repo Error: $e");
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getStocks() async {
    try {
      final remoteStocks = await remoteDataSource.getStocks();
      return remoteStocks;
    } catch (e) {
      print("⚠️ Community Repo Error: $e");
      rethrow;
    }
  }
}
