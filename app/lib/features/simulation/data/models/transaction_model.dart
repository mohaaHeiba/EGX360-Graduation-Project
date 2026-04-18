import 'package:egx/features/simulation/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.symbol,
    required super.type,
    required super.quantity,
    required super.price,
    required super.totalValue,
    super.executionType,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      symbol: json['symbol'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      totalValue: (json['total_value'] as num).toDouble(),
      executionType: (json['execution_type'] as String?) ?? 'manual',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'symbol': symbol,
      'type': type,
      'quantity': quantity,
      'price': price,
      'total_value': totalValue,
      'execution_type': executionType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TransactionEntity toEntity() => this;
}
