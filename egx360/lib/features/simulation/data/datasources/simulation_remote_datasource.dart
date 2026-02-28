import 'package:egx/features/simulation/data/models/wallet_model.dart';
import 'package:egx/features/simulation/data/models/holding_model.dart';
import 'package:egx/features/simulation/data/models/transaction_model.dart';
import 'package:egx/features/simulation/data/models/protection_rule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SimulationRemoteDataSource {
  Future<WalletModel?> getWallet(String userId);
  Future<List<HoldingModel>> getHoldings(String userId);
  Future<List<TransactionModel>> getTransactions(
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
  Future<List<ProtectionRuleModel>> getProtectionRules(String userId);
  Future<ProtectionRuleModel?> getProtectionRule(String userId, String symbol);
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

class SimulationRemoteDataSourceImpl implements SimulationRemoteDataSource {
  final SupabaseClient supabase;

  SimulationRemoteDataSourceImpl(this.supabase);

  @override
  Future<WalletModel?> getWallet(String userId) async {
    try {
      final response = await supabase
          .from('user_wallets')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return WalletModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch wallet: $e');
    }
  }

  @override
  Future<List<HoldingModel>> getHoldings(String userId) async {
    try {
      final response = await supabase
          .from('user_holdings')
          .select()
          .eq('user_id', userId)
          .gt('quantity', 0) // Only holdings with positive quantity
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => HoldingModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch holdings: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await supabase
          .from('user_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<void> executeTrade({
    required String userId,
    required String symbol,
    required String type,
    required double quantity,
    required double price,
  }) async {
    try {
      // Call the Supabase RPC function that handles all the logic
      await supabase.rpc(
        'execute_trade',
        params: {
          'p_user_id': userId,
          'p_symbol': symbol,
          'p_type': type,
          'p_quantity': quantity,
          'p_price': price,
        },
      );
    } catch (e) {
      // Supabase exceptions will contain the Arabic error messages from the function
      rethrow;
    }
  }

  // ── Protection Rules ──

  @override
  Future<List<ProtectionRuleModel>> getProtectionRules(String userId) async {
    try {
      final response = await supabase
          .from('user_protection_rules')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProtectionRuleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch protection rules: $e');
    }
  }

  @override
  Future<ProtectionRuleModel?> getProtectionRule(
    String userId,
    String symbol,
  ) async {
    try {
      final response = await supabase
          .from('user_protection_rules')
          .select()
          .eq('user_id', userId)
          .eq('symbol', symbol)
          .maybeSingle();

      if (response == null) return null;
      return ProtectionRuleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch protection rule: $e');
    }
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
    try {
      await supabase.from('user_protection_rules').upsert({
        'user_id': userId,
        'symbol': symbol,
        'alert_percentage': alertPercentage,
        'liquidation_percentage': liquidationPercentage,
        'is_alert_enabled': isAlertEnabled,
        'is_sell_enabled': isSellEnabled,
      }, onConflict: 'user_id,symbol');
    } catch (e) {
      throw Exception('Failed to save protection rule: $e');
    }
  }

  @override
  Future<void> deleteProtectionRule(String userId, String symbol) async {
    try {
      await supabase
          .from('user_protection_rules')
          .delete()
          .eq('user_id', userId)
          .eq('symbol', symbol);
    } catch (e) {
      throw Exception('Failed to delete protection rule: $e');
    }
  }
}
