import 'package:egx/features/currency/domain/repositories/currency_repository.dart';

class GetLiveCurrencyPricesUseCase {
  final CurrencyRepository repository;

  GetLiveCurrencyPricesUseCase(this.repository);

  Future<Map<String, double>> call() async {
    return await repository.getLivePrices();
  }
}
