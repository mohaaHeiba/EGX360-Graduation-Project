import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetNewsForSymbolsUseCase {
  final SearchRepository repository;

  GetNewsForSymbolsUseCase(this.repository);

  Future<List<NewsEntity>> call(List<String> symbols) {
    return repository.getNewsForSymbols(symbols);
  }
}
