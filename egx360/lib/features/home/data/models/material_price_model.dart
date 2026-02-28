import 'package:egx/features/home/domain/entities/material_price_entity.dart';

class MaterialPriceModel extends MaterialPriceEntity {
  MaterialPriceModel({
    required super.timestamp,
    required super.price24k,
    required super.price22k,
    required super.price21k,
    required super.price18k,
    required super.silver999,
    required super.silver800,
  });

  factory MaterialPriceModel.fromJson(Map<String, dynamic> json) {
    return MaterialPriceModel(
      timestamp: DateTime.parse(json['timestamp']),
      price24k: (json['price_24k'] as num?)?.toDouble() ?? 0.0,
      price22k: (json['price_22k'] as num?)?.toDouble() ?? 0.0,
      price21k: (json['price_21k'] as num?)?.toDouble() ?? 0.0,
      price18k: (json['price_18k'] as num?)?.toDouble() ?? 0.0,
      silver999: (json['silver_999'] as num?)?.toDouble() ?? 0.0,
      silver800: (json['silver_800'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
