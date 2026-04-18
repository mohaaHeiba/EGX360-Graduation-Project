import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';

abstract class SearchRepository {
  Future<List<StockEntity>> searchStocks(String query, {String? category});
  Future<List<StockEntity>> getInitialStocks({
    String? category,
    int limit = 5,
    int offset = 0,
  });
  Future<List<NewsEntity>> getLatestNews({
    String? category,
    int limit = 10,
    int offset = 0,
  });
  Future<List<NewsEntity>> getNewsForStock(
    String stockId, {
    int limit = 10,
    int offset = 0,
  });
  Future<List<NewsEntity>> getNewsForSymbols(List<String> symbols);
  Future<List<CandleEntity>> getStockCandles(
    String symbol, {
    String? candleTableName,
    DateTime? afterTime,
    String? resolution,
    int? limit,
  });
  Future<void> addToWatchlist(String userId, String symbol);
  Future<void> removeFromWatchlist(String userId, String symbol);
  Future<bool> isStockInWatchlist(String userId, String symbol);
  Future<MaterialPriceEntity?> getLatestMaterialPrice();
  Future<StockEntity> getStockBySymbol(String symbol);
  Future<AiPrediction?> getLatestAiPrediction(String symbol);
}
