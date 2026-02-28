import 'package:egx/features/simulation/domain/entities/protection_rule_entity.dart';

class ProtectionRuleModel extends ProtectionRuleEntity {
  const ProtectionRuleModel({
    required super.id,
    required super.userId,
    required super.symbol,
    super.alertPercentage,
    super.liquidationPercentage,
    super.isAlertEnabled,
    super.isSellEnabled,
    super.lastAlertSentAt,
    required super.createdAt,
  });

  factory ProtectionRuleModel.fromJson(Map<String, dynamic> json) {
    return ProtectionRuleModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      symbol: json['symbol'] as String,
      alertPercentage: (json['alert_percentage'] as num?)?.toDouble() ?? 5.0,
      liquidationPercentage:
          (json['liquidation_percentage'] as num?)?.toDouble() ?? 10.0,
      isAlertEnabled: json['is_alert_enabled'] as bool? ?? false,
      isSellEnabled: json['is_sell_enabled'] as bool? ?? false,
      lastAlertSentAt: json['last_alert_sent_at'] != null
          ? DateTime.parse(json['last_alert_sent_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symbol': symbol,
      'alert_percentage': alertPercentage,
      'liquidation_percentage': liquidationPercentage,
      'is_alert_enabled': isAlertEnabled,
      'is_sell_enabled': isSellEnabled,
    };
  }

  ProtectionRuleEntity toEntity() => this;
}
