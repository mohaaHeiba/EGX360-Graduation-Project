class MaterialPriceEntity {
  final DateTime timestamp;
  
  // Gold - Grams
  final double p24Buy;
  final double p24Sell;
  final double p21Buy;
  final double p21Sell;
  final double p18Buy;
  final double p18Sell;

  // Gold - Large Units
  final double ounceBuy;
  final double ounceSell;
  final double goldPoundBuy;
  final double goldPoundSell;

  // Gold - Bars
  final double bar50gBuy;
  final double bar50gSell;
  final double bar100gBuy;
  final double bar100gSell;
  final double bar250gBuy;
  final double bar250gSell;

  // Silver
  final double silver999Buy;
  final double silver999Sell;
  final double silver925Buy;
  final double silver925Sell;

  MaterialPriceEntity({
    required this.timestamp,
    required this.p24Buy,
    required this.p24Sell,
    required this.p21Buy,
    required this.p21Sell,
    required this.p18Buy,
    required this.p18Sell,
    required this.ounceBuy,
    required this.ounceSell,
    required this.goldPoundBuy,
    required this.goldPoundSell,
    required this.bar50gBuy,
    required this.bar50gSell,
    required this.bar100gBuy,
    required this.bar100gSell,
    required this.bar250gBuy,
    required this.bar250gSell,
    required this.silver999Buy,
    required this.silver999Sell,
    required this.silver925Buy,
    required this.silver925Sell,
  });
}
