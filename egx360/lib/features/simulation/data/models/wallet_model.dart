import 'package:egx/features/simulation/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.userId,
    required super.balance,
    required super.initialBalance,
    required super.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['user_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      initialBalance: (json['initial_balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'initial_balance': initialBalance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WalletEntity toEntity() => this;
}
