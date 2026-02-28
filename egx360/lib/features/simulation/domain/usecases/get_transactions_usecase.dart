import 'package:egx/features/simulation/domain/entities/transaction_entity.dart';
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';

class GetTransactionsUseCase {
  final SimulationRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await repository.getTransactions(
      userId,
      limit: limit,
      offset: offset,
    );
  }
}
