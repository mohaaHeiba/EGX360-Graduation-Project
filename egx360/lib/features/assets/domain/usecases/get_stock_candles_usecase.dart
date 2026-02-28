import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/assets/domain/repositories/stock_repository.dart';

class GetStockCandlesUseCase {
  final StockRepository repository;

  GetStockCandlesUseCase(this.repository);

  Future<List<CandleEntity>> call({
    required String symbol,
    required String tableName,
    required String interval,
    int limit = 100,
    DateTime? startTime,
  }) async {
    return await repository.getStockCandles(
      symbol: symbol,
      tableName: tableName,
      interval: interval,
      limit: limit,
      startTime: startTime,
    );
  }
}
