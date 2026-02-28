import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetStockDetailsUseCase {
  final HomeRepository repository;

  GetStockDetailsUseCase(this.repository);

  Future<StockModel> call(String symbol) {
    return repository.getStockDetails(symbol);
  }
}
