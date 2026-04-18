import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetStockNewsUseCase {
  final SearchRepository repository;

  GetStockNewsUseCase(this.repository);

  Future<List<NewsEntity>> call(
    String stockId, {
    int limit = 10,
    int offset = 0,
  }) {
    return repository.getNewsForStock(stockId, limit: limit, offset: offset);
  }
}
