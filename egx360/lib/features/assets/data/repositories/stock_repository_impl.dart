import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/assets/data/datasources/stock_remote_data_source.dart';
import 'package:egx/features/assets/domain/repositories/stock_repository.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;

  StockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CandleEntity>> getStockCandles({
    required String symbol,
    required String tableName,
    required String interval,
    int limit = 100,
    DateTime? startTime,
  }) async {
    // Hybrid Logic for Gold and Silver
    if (symbol == 'GOLD' || symbol == 'SILVER') {
      // For 1D and 1W (short intervals), fetch from Binance
      // Note: interval here comes from the UseCase which might be '1m' for 1D view or '1d' for 1M view.
      // We need to map the app's requested resolution to what we want from Binance.

      // If we are asking for minute-level data (usually for 1D view)
      if (interval == '1m' ||
          interval == '5m' ||
          interval == '15m' ||
          interval == '30m' ||
          interval == '1h') {
        String binanceSymbol = symbol == 'GOLD' ? 'PAXGUSDT' : 'LTCUSDT';
        String binanceInterval = interval;

        // Map '1m' to '5m' if we want to be safe or just pass it through.
        // Binance supports 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M

        print(
          'StockRepository: Switching to Binance for $symbol ($binanceSymbol) with interval $interval',
        );

        return await remoteDataSource.fetchBinanceHistoricalData(
          symbol: binanceSymbol,
          interval: binanceInterval,
          limit: limit,
        );
      }
    }

    // Default: Fetch from Supabase
    return await remoteDataSource.fetchStockCandles(
      tableName: tableName,
      interval: interval,
      limit: limit,
      startTime: startTime,
    );
  }

  @override
  Future<List<NewsEntity>> getStockNews({
    required String stockId,
    int limit = 10,
    int offset = 0,
  }) async {
    return await remoteDataSource.fetchStockNews(
      stockId: stockId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<MaterialPriceEntity> getMaterialPrice() async {
    return await remoteDataSource.fetchMaterialPrice();
  }
}
