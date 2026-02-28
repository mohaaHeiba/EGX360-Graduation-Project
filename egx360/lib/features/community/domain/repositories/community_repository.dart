import 'package:egx/features/community/domain/entity/stock_entity.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';

abstract class CommunityRepository {
  Future<List<PostEntity>> getAllPosts({
    required int limit,
    required int offset,
    String? category,
  });
  Future<List<StockEntity>> getStocks();
}
