import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetInitialStocksUseCase {
  final SearchRepository repository;

  GetInitialStocksUseCase(this.repository);

  Future<List<StockEntity>> call({
    String? category,
    int limit = 5,
    int offset = 0,
  }) {
    return repository.getInitialStocks(
      category: category,
      limit: limit,
      offset: offset,
    );
  }
}
