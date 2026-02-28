import 'package:egx/features/simulation/data/datasources/simulation_remote_datasource.dart';
import 'package:egx/features/simulation/domain/entities/wallet_entity.dart';
import 'package:egx/features/simulation/domain/entities/holding_entity.dart';
import 'package:egx/features/simulation/domain/entities/transaction_entity.dart';
import 'package:egx/features/simulation/domain/entities/protection_rule_entity.dart';
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';

class SimulationRepositoryImpl implements SimulationRepository {
  final SimulationRemoteDataSource remoteDataSource;

  SimulationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WalletEntity?> getWallet(String userId) async {
    final model = await remoteDataSource.getWallet(userId);
    return model?.toEntity();
  }

  @override
  Future<List<HoldingEntity>> getHoldings(String userId) async {
    final models = await remoteDataSource.getHoldings(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactions(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final models = await remoteDataSource.getTransactions(
      userId,
      limit: limit,
      offset: offset,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> executeTrade({
    required String userId,
    required String symbol,
    required String type,
    required double quantity,
    required double price,
  }) async {
    await remoteDataSource.executeTrade(
      userId: userId,
      symbol: symbol,
      type: type,
      quantity: quantity,
      price: price,
    );
  }

  // ── Protection Rules ──

  @override
  Future<List<ProtectionRuleEntity>> getProtectionRules(String userId) async {
    final models = await remoteDataSource.getProtectionRules(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProtectionRuleEntity?> getProtectionRule(
    String userId,
    String symbol,
  ) async {
    final model = await remoteDataSource.getProtectionRule(userId, symbol);
    return model?.toEntity();
  }

  @override
  Future<void> upsertProtectionRule({
    required String userId,
    required String symbol,
    required double alertPercentage,
    required double liquidationPercentage,
    required bool isAlertEnabled,
    required bool isSellEnabled,
  }) async {
    await remoteDataSource.upsertProtectionRule(
      userId: userId,
      symbol: symbol,
      alertPercentage: alertPercentage,
      liquidationPercentage: liquidationPercentage,
      isAlertEnabled: isAlertEnabled,
      isSellEnabled: isSellEnabled,
    );
  }

  @override
  Future<void> deleteProtectionRule(String userId, String symbol) async {
    await remoteDataSource.deleteProtectionRule(userId, symbol);
  }
}
