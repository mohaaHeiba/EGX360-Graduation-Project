import 'package:egx/features/simulation/domain/entities/wallet_entity.dart';
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';

class GetWalletUseCase {
  final SimulationRepository repository;

  GetWalletUseCase(this.repository);

  Future<WalletEntity?> call(String userId) async {
    return await repository.getWallet(userId);
  }
}
