import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/markets/domain/repositories/markets_repository.dart';
import 'package:egx/features/markets/data/datasources/markets_remote_datasource.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

/// Implementation of MarketsRepository
/// Handles data layer to domain layer conversion
class MarketsRepositoryImpl implements MarketsRepository {
  final MarketsRemoteDataSource remoteDataSource;

  MarketsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StockEntity>> searchAssets(String query) async {
    final models = await remoteDataSource.searchAssets(query);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CandleEntity>> getCandles({
    required String symbol,
    required String interval,
    int? limit,
  }) async {
    final models = await remoteDataSource.getCandles(
      symbol: symbol,
      interval: interval,
      limit: limit,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CandleEntity>> loadMoreCandles({
    required String symbol,
    required String interval,
    required DateTime before,
    int? limit,
  }) async {
    final models = await remoteDataSource.loadMoreCandles(
      symbol: symbol,
      interval: interval,
      before: before,
      limit: limit,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AiPrediction?> getLatestAiPrediction(String symbol) async {
    return await remoteDataSource.getLatestAiPrediction(symbol);
  }
}
