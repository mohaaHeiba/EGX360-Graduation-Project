import 'package:egx/features/home/domain/entities/market_history_entity.dart';

class MarketHistoryModel extends MarketHistoryEntity {
  MarketHistoryModel({
    required super.tradeDate,
    required super.marketCap,
    required super.valueTraded,
    required super.updatedAt,
  });

  factory MarketHistoryModel.fromJson(Map<String, dynamic> json) {
    return MarketHistoryModel(
      tradeDate: DateTime.parse(json['trade_date']),
      marketCap: json['market_cap'] ?? '',
      valueTraded: json['value_traded'] ?? '',
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trade_date': tradeDate.toIso8601String(),
      'market_cap': marketCap,
      'value_traded': valueTraded,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
