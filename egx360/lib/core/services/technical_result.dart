/// Represents the vote of a single technical indicator.
enum IndicatorSignal { strongBuy, buy, neutral, sell, strongSell }

/// Vote from one indicator with its details.
class IndicatorVote {
  final String name;
  final IndicatorSignal signal;
  final double? value; // The raw indicator value (e.g., RSI = 32.5)

  const IndicatorVote({required this.name, required this.signal, this.value});

  /// Numeric score: +1 buy, -1 sell, 0 neutral
  double get score {
    switch (signal) {
      case IndicatorSignal.strongBuy:
        return 1.0;
      case IndicatorSignal.buy:
        return 1.0;
      case IndicatorSignal.neutral:
        return 0.0;
      case IndicatorSignal.sell:
        return -1.0;
      case IndicatorSignal.strongSell:
        return -1.0;
    }
  }
}

/// Full result of technical analysis on a set of candle data.
class TechnicalResult {
  /// Final consensus score from -100 (Strong Sell) to +100 (Strong Buy)
  final double score;

  /// Human-readable recommendation
  final String recommendation;

  /// Individual trend indicator votes (EMA 10, 20, 50, 100)
  final List<IndicatorVote> trendVotes;

  /// Individual oscillator votes (RSI, MACD, Stochastic)
  final List<IndicatorVote> oscillatorVotes;

  /// Raw values for display
  final double? rsiValue;
  final double? macdHistogram;
  final double? stochasticK;
  final bool bollingerBuySignal;

  const TechnicalResult({
    required this.score,
    required this.recommendation,
    required this.trendVotes,
    required this.oscillatorVotes,
    this.rsiValue,
    this.macdHistogram,
    this.stochasticK,
    this.bollingerBuySignal = false,
  });

  /// Total buy / sell / neutral counts across all indicators
  int get buyCount => [...trendVotes, ...oscillatorVotes]
      .where(
        (v) =>
            v.signal == IndicatorSignal.buy ||
            v.signal == IndicatorSignal.strongBuy,
      )
      .length;

  int get sellCount => [...trendVotes, ...oscillatorVotes]
      .where(
        (v) =>
            v.signal == IndicatorSignal.sell ||
            v.signal == IndicatorSignal.strongSell,
      )
      .length;

  int get neutralCount => [
    ...trendVotes,
    ...oscillatorVotes,
  ].where((v) => v.signal == IndicatorSignal.neutral).length;

  /// Default empty result
  static const empty = TechnicalResult(
    score: 0,
    recommendation: 'Neutral',
    trendVotes: [],
    oscillatorVotes: [],
  );
}
