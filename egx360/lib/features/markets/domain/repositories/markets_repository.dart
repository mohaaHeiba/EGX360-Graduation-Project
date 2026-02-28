import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

/// Repository interface for Markets feature
/// Defines contracts for data operations
abstract class MarketsRepository {
  /// Search for stocks/crypto assets by query
  Future<List<StockEntity>> searchAssets(String query);

  /// Get candles for a specific stock/crypto
  Future<List<CandleEntity>> getCandles({
    required String symbol,
    required String interval,
    int? limit,
  });

  /// Load more historical candles before a specific time
  Future<List<CandleEntity>> loadMoreCandles({
    required String symbol,
    required String interval,
    required DateTime before,
    int? limit,
  });
}
