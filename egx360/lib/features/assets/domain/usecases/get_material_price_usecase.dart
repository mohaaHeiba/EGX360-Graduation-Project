import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/assets/domain/repositories/stock_repository.dart';

class GetMaterialPriceUseCase {
  final StockRepository repository;

  GetMaterialPriceUseCase(this.repository);

  Future<MaterialPriceEntity> call() async {
    return await repository.getMaterialPrice();
  }
}
