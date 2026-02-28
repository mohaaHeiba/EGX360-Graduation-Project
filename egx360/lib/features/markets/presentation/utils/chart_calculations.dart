import 'dart:math';
import 'package:egx/features/markets/presentation/widgets/chart_view.dart';

/// Utility class for chart calculations (Heikin-Ashi, Renko, etc.)
class ChartCalculations {
  ChartCalculations._();

  /// Calculate Heikin-Ashi candlesticks from regular candlestick data
  /// Heikin-Ashi smooths price data and helps identify trends
  static List<ChartData> calculateHeikinAshi(List<ChartData> data) {
    if (data.isEmpty) return [];
    List<ChartData> haData = [];

    double prevOpen = data.first.open;
    double prevClose = data.first.close;

    for (int i = 0; i < data.length; i++) {
      var current = data[i];
      // HA Close = (Open + High + Low + Close) / 4
      double haClose =
          (current.open + current.high + current.low + current.close) / 4;
      // HA Open = (Prev HA Open + Prev HA Close) / 2
      double haOpen = (prevOpen + prevClose) / 2;
      // HA High = Max(High, HA Open, HA Close)
      double haHigh = max(current.high, max(haOpen, haClose));
      // HA Low = Min(Low, HA Open, HA Close)
      double haLow = min(current.low, min(haOpen, haClose));

      haData.add(
        ChartData(
          index: current.index,
          x: current.x, // Keep original time
          open: haOpen,
          high: haHigh,
          low: haLow,
          close: haClose,
          volume: current.volume,
        ),
      );

      prevOpen = haOpen;
      prevClose = haClose;
    }
    return haData;
  }

  /// Calculate Renko chart from regular candlestick data
  /// Renko charts filter out noise by only showing price movements of a fixed size
  static List<ChartData> calculateRenko(List<ChartData> data) {
    if (data.isEmpty) return [];

    // 1. Calculate ATR (or just use a percentage/fixed value for simplicity initially)
    // For simplicity, let's use 0.1% of the first price as brick size or a fixed reasonable small amount
    // A better approach for crypto is often % based.
    // Let's use standard ATR-like or just Fixed step if we don't have ATR loaded.
    // Let's use Average True Range of last 14 candles or simply (High - Low) average.
    double sumRange = 0;
    for (var d in data) {
      sumRange += (d.high - d.low);
    }
    double avgRange = sumRange / data.length;
    double brickSize = avgRange > 0 ? avgRange : 1.0;
    // Alternatively, just use 1/1000th of price? No, avgRange is safer.

    List<ChartData> renkoData = [];
    double currentBrickClose = data.first.close;
    int indexCounter = 0;

    // Renko logic is price driven, disconnected from time.
    // We iterate through available data "close" prices usually.
    // We map the "Time" of the brick to the time of the candle that completed it.

    for (var i = 0; i < data.length; i++) {
      double price = data[i].close;
      double diff = price - currentBrickClose;

      // While price has moved enough to form one or more bricks
      while (diff.abs() >= brickSize) {
        bool isUp = diff > 0;
        // If we have a direction change, we might need an extra brick or valid logic
        // Standard Renko:
        // Up brick: Open = Prev Close, Close = Prev Close + BrickSize
        // Down brick: Open = Prev Close, Close = Prev Close - BrickSize

        double open = currentBrickClose;
        double close = isUp
            ? currentBrickClose + brickSize
            : currentBrickClose - brickSize;

        renkoData.add(
          ChartData(
            index: indexCounter++,
            x: data[i].x, // Maps to the time this brick was finalized
            open: open,
            high: max(open, close),
            low: min(open, close),
            close: close,
            volume: 0,
          ),
        );

        currentBrickClose = close;
        diff = price - currentBrickClose;
      }
    }

    return renkoData;
  }
}
