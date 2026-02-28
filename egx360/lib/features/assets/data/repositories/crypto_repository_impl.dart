import 'package:egx/features/assets/data/datasources/crypto_remote_data_source.dart';
import 'package:egx/features/assets/data/repositories/crypto_repository.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource remoteDataSource;

  CryptoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String interval,
    int limit = 500,
  }) async {
    return await remoteDataSource.fetchHistoricalData(
      symbol: symbol,
      interval: interval,
      limit: limit,
    );
  }

  @override
  Future<List<CandleEntity>> getHistoricalData({
    required String symbol,
    required String interval,
    int limit = 500,
  }) async {
    return await fetchHistoricalData(
      symbol: symbol,
      interval: interval,
      limit: limit,
    );
  }

  @override
  Future<Map<String, dynamic>> fetch24hrTicker(String symbol) async {
    return await remoteDataSource.fetch24hrTicker(symbol);
  }

  @override
  Future<Map<String, dynamic>> get24hrTicker(String symbol) async {
    return await fetch24hrTicker(symbol);
  }
}
