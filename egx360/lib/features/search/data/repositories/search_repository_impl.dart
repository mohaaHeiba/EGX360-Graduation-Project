import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/search/data/datasources/search_remote_datasource.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StockEntity>> searchStocks(
    String query, {
    String? category,
  }) async {
    return await remoteDataSource.searchStocks(query, category: category);
  }

  @override
  Future<List<StockEntity>> getInitialStocks({
    String? category,
    int limit = 5,
    int offset = 0,
  }) async {
    return await remoteDataSource.getInitialStocks(
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<NewsEntity>> getLatestNews({
    String? category,
    int limit = 10,
    int offset = 0,
  }) async {
    return await remoteDataSource.getLatestNews(
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<NewsEntity>> getNewsForStock(
    String stockId, {
    int limit = 10,
    int offset = 0,
  }) async {
    return await remoteDataSource.getNewsForStock(
      stockId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<NewsEntity>> getNewsForSymbols(List<String> symbols) async {
    return await remoteDataSource.getNewsForSymbols(symbols);
  }

  @override
  Future<List<CandleEntity>> getStockCandles(
    String symbol, {
    String? candleTableName,
    DateTime? afterTime,
    String? resolution,
    int? limit,
  }) async {
    return await remoteDataSource.getStockCandles(
      symbol,
      candleTableName: candleTableName,
      afterTime: afterTime,
      resolution: resolution,
      limit: limit,
    );
  }

  @override
  Future<void> addToWatchlist(String userId, String symbol) async {
    return await remoteDataSource.addToWatchlist(userId, symbol);
  }

  @override
  Future<void> removeFromWatchlist(String userId, String symbol) async {
    return await remoteDataSource.removeFromWatchlist(userId, symbol);
  }

  @override
  Future<bool> isStockInWatchlist(String userId, String symbol) async {
    return await remoteDataSource.isStockInWatchlist(userId, symbol);
  }

  @override
  Future<MaterialPriceEntity?> getLatestMaterialPrice() async {
    return await remoteDataSource.getLatestMaterialPrice();
  }

  @override
  Future<StockEntity> getStockBySymbol(String symbol) async {
    return await remoteDataSource.getStockBySymbol(symbol);
  }

  @override
  Future<AiPrediction?> getLatestAiPrediction(String symbol) async {
    return await remoteDataSource.getLatestAiPrediction(symbol);
  }
}
