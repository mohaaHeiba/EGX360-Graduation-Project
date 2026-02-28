import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetLatestNewsUseCase {
  final SearchRepository repository;

  GetLatestNewsUseCase(this.repository);

  Future<List<NewsEntity>> call({
    String? category,
    int limit = 10,
    int offset = 0,
  }) {
    return repository.getLatestNews(
      category: category,
      limit: limit,
      offset: offset,
    );
  }
}
