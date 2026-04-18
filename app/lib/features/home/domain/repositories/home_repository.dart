import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/data/models/news_model.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/home/domain/entities/market_history_entity.dart';

abstract class HomeRepository {
  Future<List<StockModel>> getTrendingStocks({int limit = 10});
  Future<List<StockModel>> getMarketIndices();
  Future<List<NewsModel>> getLatestNews({int limit = 5});
  Future<Map<String, dynamic>> getMarketOverview();
  Future<List<StockModel>> getWatchlist(
    String userId, {
    int limit = 5,
    int offset = 0,
  });
  Future<MaterialPriceEntity?> getLatestMaterialPrice();
  Future<MarketHistoryEntity?> getMarketHistory();
  Future<void> removeFromWatchlist(String userId, String symbol);
  Future<StockModel> getStockDetails(String symbol);
}
