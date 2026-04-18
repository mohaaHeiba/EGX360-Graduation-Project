import 'package:egx/features/simulation/domain/entities/wallet_entity.dart';
import 'package:egx/features/simulation/domain/entities/holding_entity.dart';
import 'package:egx/features/simulation/domain/entities/transaction_entity.dart';
import 'package:egx/features/simulation/domain/entities/protection_rule_entity.dart';

abstract class SimulationRepository {
  Future<WalletEntity?> getWallet(String userId);
  Future<List<HoldingEntity>> getHoldings(String userId);
  Future<List<TransactionEntity>> getTransactions(
    String userId, {
    int limit = 50,
    int offset = 0,
  });
  Future<void> executeTrade({
    required String userId,
    required String symbol,
    required String type,
    required double quantity,
    required double price,
  });

  // Protection Rules
  Future<List<ProtectionRuleEntity>> getProtectionRules(String userId);
  Future<ProtectionRuleEntity?> getProtectionRule(String userId, String symbol);
  Future<void> upsertProtectionRule({
    required String userId,
    required String symbol,
    required double alertPercentage,
    required double liquidationPercentage,
    required bool isAlertEnabled,
    required bool isSellEnabled,
  });
  Future<void> deleteProtectionRule(String userId, String symbol);
}
