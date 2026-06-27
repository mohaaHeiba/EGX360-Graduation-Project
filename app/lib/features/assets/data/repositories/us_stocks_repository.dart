import 'package:egx/features/search/domain/entities/candle_entity.dart';

/// Repository contract for US Stocks hybrid data (Massive + Finnhub).
abstract class UsStocksRepository {
  /// Fetch historical EOD candles from Massive/Polygon.
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String timespan,
    required String from,
    required String to,
    int multiplier = 1,
  });

  /// Fetch live quote from Finnhub.
  Future<Map<String, dynamic>> fetchQuote(String symbol);

  /// Build a synthetic live candle from Finnhub quote data.
  CandleEntity buildLiveCandleFromQuote(Map<String, dynamic> quoteData);
}
