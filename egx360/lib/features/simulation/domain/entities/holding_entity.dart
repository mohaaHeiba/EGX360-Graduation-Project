import 'package:equatable/equatable.dart';

class HoldingEntity extends Equatable {
  final String userId;
  final String symbol;
  final double quantity;
  final double averagePrice;
  final DateTime updatedAt;

  const HoldingEntity({
    required this.userId,
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    symbol,
    quantity,
    averagePrice,
    updatedAt,
  ];
}
