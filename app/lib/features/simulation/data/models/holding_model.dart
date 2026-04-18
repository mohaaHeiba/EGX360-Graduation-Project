import 'package:egx/features/simulation/domain/entities/holding_entity.dart';

class HoldingModel extends HoldingEntity {
  const HoldingModel({
    required super.userId,
    required super.symbol,
    required super.quantity,
    required super.averagePrice,
    required super.updatedAt,
  });

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      userId: json['user_id'] as String,
      symbol: json['symbol'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      averagePrice: (json['average_price'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symbol': symbol,
      'quantity': quantity,
      'average_price': averagePrice,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HoldingEntity toEntity() => this;
}
