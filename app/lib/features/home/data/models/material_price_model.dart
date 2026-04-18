import 'package:egx/features/home/domain/entities/material_price_entity.dart';

class MaterialPriceModel extends MaterialPriceEntity {
  MaterialPriceModel({
    required super.timestamp,
    required super.p24Buy,
    required super.p24Sell,
    required super.p21Buy,
    required super.p21Sell,
    required super.p18Buy,
    required super.p18Sell,
    required super.ounceBuy,
    required super.ounceSell,
    required super.goldPoundBuy,
    required super.goldPoundSell,
    required super.bar50gBuy,
    required super.bar50gSell,
    required super.bar100gBuy,
    required super.bar100gSell,
    required super.bar250gBuy,
    required super.bar250gSell,
    required super.silver999Buy,
    required super.silver999Sell,
    required super.silver925Buy,
    required super.silver925Sell,
  });

  factory MaterialPriceModel.fromJson(Map<String, dynamic> json) {
    return MaterialPriceModel(
      timestamp: DateTime.parse(json['timestamp']),
      p24Buy: (json['p24_buy'] as num?)?.toDouble() ?? 0.0,
      p24Sell: (json['p24_sell'] as num?)?.toDouble() ?? 0.0,
      p21Buy: (json['p21_buy'] as num?)?.toDouble() ?? 0.0,
      p21Sell: (json['p21_sell'] as num?)?.toDouble() ?? 0.0,
      p18Buy: (json['p18_buy'] as num?)?.toDouble() ?? 0.0,
      p18Sell: (json['p18_sell'] as num?)?.toDouble() ?? 0.0,
      ounceBuy: (json['ounce_buy'] as num?)?.toDouble() ?? 0.0,
      ounceSell: (json['ounce_sell'] as num?)?.toDouble() ?? 0.0,
      goldPoundBuy: (json['gold_pound_buy'] as num?)?.toDouble() ?? 0.0,
      goldPoundSell: (json['gold_pound_sell'] as num?)?.toDouble() ?? 0.0,
      bar50gBuy: (json['bar_50g_buy'] as num?)?.toDouble() ?? 0.0,
      bar50gSell: (json['bar_50g_sell'] as num?)?.toDouble() ?? 0.0,
      bar100gBuy: (json['bar_100g_buy'] as num?)?.toDouble() ?? 0.0,
      bar100gSell: (json['bar_100g_sell'] as num?)?.toDouble() ?? 0.0,
      bar250gBuy: (json['bar_250g_buy'] as num?)?.toDouble() ?? 0.0,
      bar250gSell: (json['bar_250g_sell'] as num?)?.toDouble() ?? 0.0,
      silver999Buy: (json['silver_999_buy'] as num?)?.toDouble() ?? 0.0,
      silver999Sell: (json['silver_999_sell'] as num?)?.toDouble() ?? 0.0,
      silver925Buy: (json['silver_925_buy'] as num?)?.toDouble() ?? 0.0,
      silver925Sell: (json['silver_925_sell'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
