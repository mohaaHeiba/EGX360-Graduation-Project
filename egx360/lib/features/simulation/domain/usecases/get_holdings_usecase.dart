import 'package:egx/features/simulation/domain/entities/holding_entity.dart';
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';

class GetHoldingsUseCase {
  final SimulationRepository repository;

  GetHoldingsUseCase(this.repository);

  Future<List<HoldingEntity>> call(String userId) async {
    return await repository.getHoldings(userId);
  }
}
