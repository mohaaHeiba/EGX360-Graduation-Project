import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/assets/domain/repositories/stock_repository.dart';

class GetStockNewsUseCase {
  final StockRepository repository;

  GetStockNewsUseCase(this.repository);

  Future<List<NewsEntity>> call({
    required String stockId,
    int limit = 10,
    int offset = 0,
  }) async {
    return await repository.getStockNews(
      stockId: stockId,
      limit: limit,
      offset: offset,
    );
  }
}
