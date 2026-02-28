import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetStockCandlesUseCase {
  final SearchRepository repository;

  GetStockCandlesUseCase(this.repository);

  Future<List<CandleEntity>> call(
    String symbol, {
    String? candleTableName,
    DateTime? afterTime,
    String? resolution,
    int? limit,
  }) {
    return repository.getStockCandles(
      symbol,
      candleTableName: candleTableName,
      afterTime: afterTime,
      resolution: resolution,
      limit: limit,
    );
  }
}
