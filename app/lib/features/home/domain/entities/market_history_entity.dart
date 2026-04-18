class MarketHistoryEntity {
  final DateTime tradeDate;
  final String marketCap;
  final String valueTraded;
  final DateTime updatedAt;

  MarketHistoryEntity({
    required this.tradeDate,
    required this.marketCap,
    required this.valueTraded,
    required this.updatedAt,
  });
}
