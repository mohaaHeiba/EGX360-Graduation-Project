import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetMaterialPriceUseCase {
  final HomeRepository repository;

  GetMaterialPriceUseCase(this.repository);

  Future<MaterialPriceEntity?> call() {
    return repository.getLatestMaterialPrice();
  }
}
