/// Entity representing an AI-generated probability prediction for a stock.
class AiPrediction {
  final String symbol;
  final double closePrice;
  final double probability; // 0.0 to 1.0 (bullishness probability)
  final DateTime createdAt;

  const AiPrediction({
    required this.symbol,
    required this.closePrice,
    required this.probability,
    required this.createdAt,
  });

  /// Recommendation based on probability thresholds.
  String get recommendation {
    if (probability >= 0.8) return 'Strong Buy';
    if (probability >= 0.6) return 'Buy';
    if (probability <= 0.2) return 'Strong Sell';
    if (probability <= 0.4) return 'Sell';
    return 'Neutral';
  }

  /// Score normalized to -100 to +100 to match the Technical Gauge.
  double get score => (probability * 200) - 100;
}
