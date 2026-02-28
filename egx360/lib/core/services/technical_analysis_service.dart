import 'dart:math' as math;
import 'package:egx/core/services/technical_result.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

/// Pure-math technical analysis engine.
/// All methods are static — no state, no side-effects, easily testable.
class TechnicalAnalysisService {
  TechnicalAnalysisService._(); // Prevent instantiation

  // ─── PUBLIC API ───────────────────────────────────────────────────

  /// Calculate the full Technical Score from candle data.
  ///
  /// [candles] must be sorted chronologically (oldest → newest).
  /// [isEgx] adjusts for EGX's low-liquidity characteristics.
  static TechnicalResult calculateTechnicalScore(
    List<CandleEntity> candles, {
    bool isEgx = false,
  }) {
    if (candles.length < 20) {
      // Not enough data for meaningful analysis
      return TechnicalResult.empty;
    }

    final closes = candles.map((c) => c.close).toList();
    final highs = candles.map((c) => c.high).toList();
    final lows = candles.map((c) => c.low).toList();
    final currentPrice = closes.last;

    // ── 1. Trend Indicators (50% weight) ──
    final trendVotes = <IndicatorVote>[];

    // EMA 10
    final ema10 = _calculateEMA(closes, 10);
    if (ema10 != null) {
      trendVotes.add(
        IndicatorVote(
          name: 'EMA 10',
          signal: currentPrice > ema10
              ? IndicatorSignal.buy
              : IndicatorSignal.sell,
          value: ema10,
        ),
      );
    }

    // EMA 20
    final ema20 = _calculateEMA(closes, 20);
    if (ema20 != null) {
      trendVotes.add(
        IndicatorVote(
          name: 'EMA 20',
          signal: currentPrice > ema20
              ? IndicatorSignal.buy
              : IndicatorSignal.sell,
          value: ema20,
        ),
      );
    }

    // EMA 50
    if (closes.length >= 50) {
      final ema50 = _calculateEMA(closes, 50);
      if (ema50 != null) {
        trendVotes.add(
          IndicatorVote(
            name: 'EMA 50',
            signal: currentPrice > ema50
                ? IndicatorSignal.buy
                : IndicatorSignal.sell,
            value: ema50,
          ),
        );
      }
    }

    // EMA 100
    if (closes.length >= 100) {
      final ema100 = _calculateEMA(closes, 100);
      if (ema100 != null) {
        trendVotes.add(
          IndicatorVote(
            name: 'EMA 100',
            signal: currentPrice > ema100
                ? IndicatorSignal.buy
                : IndicatorSignal.sell,
            value: ema100,
          ),
        );
      }
    }

    // ── 2. Oscillators (50% weight) ──
    final oscillatorVotes = <IndicatorVote>[];

    // RSI
    final rsi = _calculateRSI(closes, 14);
    if (rsi != null) {
      IndicatorSignal rsiSignal;
      if (rsi < 30) {
        rsiSignal = IndicatorSignal.buy; // Oversold → Buy
      } else if (rsi > 70) {
        rsiSignal = IndicatorSignal.sell; // Overbought → Sell
      } else {
        rsiSignal = IndicatorSignal.neutral;
      }
      oscillatorVotes.add(
        IndicatorVote(name: 'RSI (14)', signal: rsiSignal, value: rsi),
      );
    }

    // MACD
    final macd = _calculateMACD(closes);
    if (macd != null) {
      final histogram = macd['histogram']!;
      IndicatorSignal macdSignal;
      if (histogram > 0) {
        macdSignal = IndicatorSignal.buy; // MACD above signal → Buy
      } else if (histogram < 0) {
        macdSignal = IndicatorSignal.sell; // MACD below signal → Sell
      } else {
        macdSignal = IndicatorSignal.neutral;
      }
      oscillatorVotes.add(
        IndicatorVote(name: 'MACD', signal: macdSignal, value: histogram),
      );
    }

    // Stochastic
    Map<String, double>? stoch;
    if (closes.length >= 14) {
      stoch = _calculateStochastic(highs, lows, closes, 14, 3);
      if (stoch != null) {
        final k = stoch['k']!;
        IndicatorSignal stochSignal;
        if (k < 20) {
          stochSignal = IndicatorSignal.buy; // Oversold
        } else if (k > 80) {
          stochSignal = IndicatorSignal.sell; // Overbought
        } else {
          stochSignal = IndicatorSignal.neutral;
        }
        oscillatorVotes.add(
          IndicatorVote(name: 'Stochastic', signal: stochSignal, value: k),
        );
      }
    }

    // ── 3. Bollinger Bands bonus (Crypto only) ──
    bool bollingerBuy = false;
    if (!isEgx && closes.length >= 20) {
      final bb = _calculateBollingerBands(closes, 20, 2.0);
      if (bb != null && rsi != null) {
        // Price touching lower band + RSI oversold → strong buy signal
        if (currentPrice <= bb['lower']! && rsi < 30) {
          bollingerBuy = true;
        }
      }
    }

    // ── 4. Compute Weighted Score ──
    double trendScore = 0;
    if (trendVotes.isNotEmpty) {
      trendScore =
          trendVotes.map((v) => v.score).reduce((a, b) => a + b) /
          trendVotes.length;
    }

    double oscillatorScore = 0;
    if (oscillatorVotes.isNotEmpty) {
      oscillatorScore =
          oscillatorVotes.map((v) => v.score).reduce((a, b) => a + b) /
          oscillatorVotes.length;
    }

    // Weighted average: 50% trend + 50% oscillators
    double rawScore = (trendScore * 0.5) + (oscillatorScore * 0.5);

    // Bollinger bonus: push toward buy by 15%
    if (bollingerBuy) {
      rawScore = (rawScore + 0.15).clamp(-1.0, 1.0);
    }

    // Scale from [-1, 1] to [-100, 100]
    final finalScore = (rawScore * 100).clamp(-100.0, 100.0);

    // Determine recommendation
    String recommendation;
    if (finalScore <= -50) {
      recommendation = 'Strong Sell';
    } else if (finalScore <= -15) {
      recommendation = 'Sell';
    } else if (finalScore < 15) {
      recommendation = 'Neutral';
    } else if (finalScore < 50) {
      recommendation = 'Buy';
    } else {
      recommendation = 'Strong Buy';
    }

    return TechnicalResult(
      score: finalScore,
      recommendation: recommendation,
      trendVotes: trendVotes,
      oscillatorVotes: oscillatorVotes,
      rsiValue: rsi,
      macdHistogram: macd?['histogram'],
      stochasticK: stoch != null ? stoch['k'] : null,
      bollingerBuySignal: bollingerBuy,
    );
  }

  // ─── PRIVATE CALCULATIONS ─────────────────────────────────────────

  /// Calculate the latest EMA value for a given period.
  static double? _calculateEMA(List<double> data, int period) {
    if (data.length < period) return null;

    // Start with SMA of first `period` values
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += data[i];
    }
    double ema = sum / period;

    // Multiplier
    final multiplier = 2.0 / (period + 1);

    // Calculate EMA for rest of data
    for (int i = period; i < data.length; i++) {
      ema = (data[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  /// Calculate the latest RSI value.
  static double? _calculateRSI(List<double> data, int period) {
    if (data.length < period + 1) return null;

    double avgGain = 0;
    double avgLoss = 0;

    // First average: simple average of gains/losses
    for (int i = 1; i <= period; i++) {
      final change = data[i] - data[i - 1];
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }
    avgGain /= period;
    avgLoss /= period;

    // Subsequent values: smoothed average
    for (int i = period + 1; i < data.length; i++) {
      final change = data[i] - data[i - 1];
      if (change > 0) {
        avgGain = (avgGain * (period - 1) + change) / period;
        avgLoss = (avgLoss * (period - 1)) / period;
      } else {
        avgGain = (avgGain * (period - 1)) / period;
        avgLoss = (avgLoss * (period - 1) + change.abs()) / period;
      }
    }

    if (avgLoss == 0) return 100.0; // All gains
    final rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1 + rs));
  }

  /// Calculate MACD (12, 26, 9).
  /// Returns {macd, signal, histogram} or null.
  static Map<String, double>? _calculateMACD(List<double> data) {
    if (data.length < 26) return null;

    final ema12 = _calculateEMA(data, 12);
    final ema26 = _calculateEMA(data, 26);
    if (ema12 == null || ema26 == null) return null;

    // Build full MACD line to compute signal line
    // We need at least 26 + 9 = 35 data points for a proper signal line
    final macdLine = <double>[];

    // Build EMA12 series
    double sum12 = 0;
    for (int i = 0; i < 12; i++) sum12 += data[i];
    double runningEma12 = sum12 / 12;
    final mult12 = 2.0 / 13;

    double sum26 = 0;
    for (int i = 0; i < 26; i++) sum26 += data[i];
    double runningEma26 = sum26 / 26;
    final mult26 = 2.0 / 27;

    // We can only compute MACD from index 25 onwards (where both EMAs exist)
    // But for simplicity, compute from index 26
    for (int i = 26; i < data.length; i++) {
      // Update EMAs
      runningEma12 = (data[i] - runningEma12) * mult12 + runningEma12;
      runningEma26 = (data[i] - runningEma26) * mult26 + runningEma26;
      macdLine.add(runningEma12 - runningEma26);
    }

    if (macdLine.length < 9) {
      // Not enough for signal line, just return raw MACD
      final lastMacd = ema12 - ema26;
      return {'macd': lastMacd, 'signal': lastMacd, 'histogram': 0};
    }

    // Signal line = 9-period EMA of MACD line
    double sumSignal = 0;
    for (int i = 0; i < 9; i++) sumSignal += macdLine[i];
    double signal = sumSignal / 9;
    final multSignal = 2.0 / 10;

    for (int i = 9; i < macdLine.length; i++) {
      signal = (macdLine[i] - signal) * multSignal + signal;
    }

    final lastMacd = macdLine.last;
    return {'macd': lastMacd, 'signal': signal, 'histogram': lastMacd - signal};
  }

  /// Calculate Stochastic Oscillator (%K and %D).
  /// [kPeriod] = lookback (default 14), [dPeriod] = smoothing (default 3).
  static Map<String, double>? _calculateStochastic(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int kPeriod,
    int dPeriod,
  ) {
    if (closes.length < kPeriod) return null;

    final kValues = <double>[];

    for (int i = kPeriod - 1; i < closes.length; i++) {
      double highestHigh = double.negativeInfinity;
      double lowestLow = double.infinity;

      for (int j = i - kPeriod + 1; j <= i; j++) {
        if (highs[j] > highestHigh) highestHigh = highs[j];
        if (lows[j] < lowestLow) lowestLow = lows[j];
      }

      final range = highestHigh - lowestLow;
      final k = range == 0 ? 50.0 : ((closes[i] - lowestLow) / range) * 100;
      kValues.add(k);
    }

    if (kValues.isEmpty) return null;

    // %D = dPeriod SMA of %K
    double d = kValues.last;
    if (kValues.length >= dPeriod) {
      double sum = 0;
      for (int i = kValues.length - dPeriod; i < kValues.length; i++) {
        sum += kValues[i];
      }
      d = sum / dPeriod;
    }

    return {'k': kValues.last, 'd': d};
  }

  /// Calculate Bollinger Bands (SMA ± stdDev).
  /// Returns {upper, middle, lower}.
  static Map<String, double>? _calculateBollingerBands(
    List<double> data,
    int period,
    double numStdDev,
  ) {
    if (data.length < period) return null;

    // SMA of last `period` values
    double sum = 0;
    final start = data.length - period;
    for (int i = start; i < data.length; i++) {
      sum += data[i];
    }
    final sma = sum / period;

    // Standard deviation
    double sumSquaredDiff = 0;
    for (int i = start; i < data.length; i++) {
      sumSquaredDiff += (data[i] - sma) * (data[i] - sma);
    }
    final stdDev = math.sqrt(sumSquaredDiff / period);

    return {
      'upper': sma + (numStdDev * stdDev),
      'middle': sma,
      'lower': sma - (numStdDev * stdDev),
    };
  }
}
