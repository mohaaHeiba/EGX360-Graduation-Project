import 'package:egx/features/assets/data/datasources/us_stocks_remote_data_source.dart';
import 'package:egx/features/assets/data/repositories/us_stocks_repository.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

class UsStocksRepositoryImpl implements UsStocksRepository {
  final UsStocksRemoteDataSource remoteDataSource;

  UsStocksRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String timespan,
    required String from,
    required String to,
    int multiplier = 1,
  }) async {
    return await remoteDataSource.fetchHistoricalData(
      symbol: symbol,
      timespan: timespan,
      from: from,
      to: to,
      multiplier: multiplier,
    );
  }

  @override
  Future<Map<String, dynamic>> fetchQuote(String symbol) async {
    return await remoteDataSource.fetchQuote(symbol);
  }

  @override
  CandleEntity buildLiveCandleFromQuote(Map<String, dynamic> quoteData) {
    return remoteDataSource.buildLiveCandleFromQuote(quoteData);
  }
}
