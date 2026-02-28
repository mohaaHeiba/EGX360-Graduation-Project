class CandlestickData {
  final double open;
  final double close;
  final double high;
  final double low;
  final bool isGreen;

  CandlestickData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  }) : isGreen = close > open;
}
