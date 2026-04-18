import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetMarketOverview {
  final HomeRepository repository;

  GetMarketOverview(this.repository);

  Future<Map<String, dynamic>> call() {
    return repository.getMarketOverview();
  }
}
