import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';

class ExecuteTradeUseCase {
  final SimulationRepository repository;

  ExecuteTradeUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String symbol,
    required String type,
    required double quantity,
    required double price,
  }) async {
    // Validate input
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }
    if (price <= 0) {
      throw Exception('Price must be greater than 0');
    }
    if (type != 'buy' && type != 'sell') {
      throw Exception('Type must be either "buy" or "sell"');
    }

    await repository.executeTrade(
      userId: userId,
      symbol: symbol,
      type: type,
      quantity: quantity,
      price: price,
    );
  }
}
