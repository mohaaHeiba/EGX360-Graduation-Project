import 'package:egx/features/search/domain/entities/candle_entity.dart';

class CandleAggregator {
  /// Aggregates a list of [CandleEntity] into larger intervals.
  ///
  /// [candles] must be sorted by time ascending.
  /// [intervalMinutes] is the target duration of each bar in minutes.
  static List<CandleEntity> aggregate(
    List<CandleEntity> candles,
    int intervalMinutes,
  ) {
    if (candles.isEmpty) return [];

    final List<CandleEntity> aggregated = [];
    final intervalDuration = Duration(minutes: intervalMinutes);

    // Start with the first candle's time rounded down to the nearest interval
    // or just use the first candle's time as the anchor.
    // For simplicity, we'll anchor to the first candle's time.

    DateTime currentIntervalStart = candles.first.candleTime;
    DateTime nextIntervalStart = currentIntervalStart.add(intervalDuration);

    double open = candles.first.open;
    double high = candles.first.high;
    double low = candles.first.low;
    double close = candles.first.close;
    int volume = candles.first.volume;
    String? timeframe =
        candles.first.timeframe; // Keep original timeframe or null

    for (int i = 1; i < candles.length; i++) {
      final candle = candles[i];

      if (candle.candleTime.isBefore(nextIntervalStart)) {
        // Accumulate in current interval
        high = candle.high > high ? candle.high : high;
        low = candle.low < low ? candle.low : low;
        close = candle.close; // Close is always the last one seen
        volume += candle.volume;
      } else {
        // Push the completed interval
        aggregated.add(
          CandleEntity(
            candleTime: currentIntervalStart,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            timeframe: timeframe,
          ),
        );

        // Start new interval
        // Align next interval start to the current candle's time
        // Alternatively, we could strictly follow clock time (e.g. 10:00, 10:30)
        // But anchoring to data is often safer for sparse data.
        currentIntervalStart = candle.candleTime;
        nextIntervalStart = currentIntervalStart.add(intervalDuration);

        open = candle.open;
        high = candle.high;
        low = candle.low;
        close = candle.close;
        volume = candle.volume;
        timeframe = candle.timeframe;
      }
    }

    // Add the last partial interval
    aggregated.add(
      CandleEntity(
        candleTime: currentIntervalStart,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
        timeframe: timeframe,
      ),
    );

    return aggregated;
  }
}
