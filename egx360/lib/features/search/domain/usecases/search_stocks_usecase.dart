import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class SearchStocksUseCase {
  final SearchRepository repository;

  SearchStocksUseCase(this.repository);

  Future<List<StockEntity>> call(String query, {String? category}) {
    return repository.searchStocks(query, category: category);
  }
}
