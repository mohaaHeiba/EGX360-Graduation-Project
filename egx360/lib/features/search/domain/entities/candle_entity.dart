class CandleEntity {
  final int? id;
  final DateTime candleTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final String? timeframe;

  CandleEntity({
    this.id,
    required this.candleTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.timeframe,
  });
}
