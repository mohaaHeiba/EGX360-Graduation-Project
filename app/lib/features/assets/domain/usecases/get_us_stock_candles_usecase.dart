import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/assets/data/repositories/us_stocks_repository.dart';

class GetUsStockCandlesUseCase {
  final UsStocksRepository repository;

  GetUsStockCandlesUseCase(this.repository);

  /// Fetch historical EOD candles + append a live candle from Finnhub quote.
  ///
  /// [timespan] must be 'day', 'week', or 'month'.
  /// Returns the merged list with the live candle appended.
  Future<List<CandleEntity>> call({
    required String symbol,
    required String timespan,
    required String from,
    required String to,
    int multiplier = 1,
    bool appendLiveCandle = true,
  }) async {
    // 1. Fetch historical EOD candles from Massive/Polygon
    final historicalCandles = await repository.fetchHistoricalData(
      symbol: symbol,
      timespan: timespan,
      from: from,
      to: to,
      multiplier: multiplier,
    );

    if (!appendLiveCandle) return historicalCandles;

    // 2. Fetch the live quote from Finnhub
    try {
      final quoteData = await repository.fetchQuote(symbol);

      // Skip if quote has no data (market closed, etc.)
      final currentPrice = (quoteData['c'] as num?)?.toDouble() ?? 0.0;
      if (currentPrice == 0.0) return historicalCandles;

      // 3. Build today's synthetic live candle
      final liveCandle = repository.buildLiveCandleFromQuote(quoteData);

      // 4. Only append if the live candle is newer than the last historical candle
      if (historicalCandles.isNotEmpty) {
        final lastHistorical = historicalCandles.last;
        // Check if the live candle is from a newer day
        final lastDate = DateTime(
          lastHistorical.candleTime.year,
          lastHistorical.candleTime.month,
          lastHistorical.candleTime.day,
        );
        final liveDate = DateTime(
          liveCandle.candleTime.year,
          liveCandle.candleTime.month,
          liveCandle.candleTime.day,
        );

        if (liveDate.isAfter(lastDate)) {
          return [...historicalCandles, liveCandle];
        } else if (liveDate.isAtSameMomentAs(lastDate)) {
          // Same day — replace the last candle with the live one
          // (Massive might have today's partial data)
          final merged = List<CandleEntity>.from(historicalCandles);
          merged[merged.length - 1] = liveCandle;
          return merged;
        }
      }

      // If no historical data, just return the live candle
      return historicalCandles.isEmpty ? [liveCandle] : historicalCandles;
    } catch (e) {
      // If Finnhub quote fails, still return historical data
      print('Warning: Failed to append live candle: $e');
      return historicalCandles;
    }
  }
}
