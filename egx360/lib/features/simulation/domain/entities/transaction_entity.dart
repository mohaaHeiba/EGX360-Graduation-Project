import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final int id;
  final String userId;
  final String symbol;
  final String type; // 'buy' or 'sell'
  final double quantity;
  final double price;
  final double totalValue;
  final String executionType; // 'manual' or 'auto_protection'
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalValue,
    this.executionType = 'manual',
    required this.createdAt,
  });

  bool get isBuy => type == 'buy';
  bool get isSell => type == 'sell';
  bool get isAutoProtection => executionType == 'auto_protection';

  @override
  List<Object?> get props => [
    id,
    userId,
    symbol,
    type,
    quantity,
    price,
    totalValue,
    executionType,
    createdAt,
  ];
}
