import 'package:egx/features/search/domain/entities/candle_entity.dart';

abstract class CryptoRepository {
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String interval,
    int limit = 500,
  });

  Future<List<CandleEntity>> getHistoricalData({
    required String symbol,
    required String interval,
    int limit = 500,
  });

  Future<Map<String, dynamic>> fetch24hrTicker(String symbol);

  Future<Map<String, dynamic>> get24hrTicker(String symbol);
}
