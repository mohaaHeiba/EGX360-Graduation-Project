import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetTrendingStocks {
  final HomeRepository repository;

  GetTrendingStocks(this.repository);

  Future<List<StockModel>> call({int limit = 10}) {
    return repository.getTrendingStocks(limit: limit);
  }
}
