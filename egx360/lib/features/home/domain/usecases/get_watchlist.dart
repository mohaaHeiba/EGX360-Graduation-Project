import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetWatchlist {
  final HomeRepository repository;

  GetWatchlist(this.repository);

  Future<List<StockModel>> call(
    String userId, {
    int limit = 5,
    int offset = 0,
  }) async {
    final result = await repository.getWatchlist(
      userId,
      limit: limit,
      offset: offset,
    );
    // Cast to StockModel list as repository returns StockEntity which StockModel extends
    return result.cast<StockModel>();
  }
}
