import 'package:equatable/equatable.dart';

class ProtectionRuleEntity extends Equatable {
  final int id;
  final String userId;
  final String symbol;
  final double alertPercentage;
  final double liquidationPercentage;
  final bool isAlertEnabled;
  final bool isSellEnabled;
  final DateTime? lastAlertSentAt;
  final DateTime createdAt;

  const ProtectionRuleEntity({
    required this.id,
    required this.userId,
    required this.symbol,
    this.alertPercentage = 5.0,
    this.liquidationPercentage = 10.0,
    this.isAlertEnabled = false,
    this.isSellEnabled = false,
    this.lastAlertSentAt,
    required this.createdAt,
  });

  /// Whether any protection feature is active
  bool get isActive => isAlertEnabled || isSellEnabled;

  @override
  List<Object?> get props => [
    id,
    userId,
    symbol,
    alertPercentage,
    liquidationPercentage,
    isAlertEnabled,
    isSellEnabled,
    lastAlertSentAt,
    createdAt,
  ];
}
