import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String userId;
  final double balance;
  final double initialBalance;
  final DateTime createdAt;

  const WalletEntity({
    required this.userId,
    required this.balance,
    required this.initialBalance,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, balance, initialBalance, createdAt];
}
