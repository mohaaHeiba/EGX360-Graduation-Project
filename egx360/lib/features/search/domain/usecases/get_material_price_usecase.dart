import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetMaterialPriceUseCase {
  final SearchRepository repository;

  GetMaterialPriceUseCase(this.repository);

  Future<MaterialPriceEntity?> call() async {
    return await repository.getLatestMaterialPrice();
  }
}
