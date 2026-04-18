import 'package:egx/features/assets/domain/repositories/asset_repository.dart';

class GetCurrencyLivePricesUseCase {
  final AssetRepository repository;

  GetCurrencyLivePricesUseCase(this.repository);

  Future<Map<String, double>> call() async {
    return await repository.getCurrencyLivePrices();
  }
}
