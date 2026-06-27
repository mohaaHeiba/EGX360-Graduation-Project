import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class PopulateExternalPricesUseCase {
  final HomeRepository repository;

  PopulateExternalPricesUseCase(this.repository);

  Future<List<StockModel>> call(List<StockModel> stocks) async {
    return await repository.populateExternalPrices(stocks);
  }
}
