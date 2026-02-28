import 'package:egx/features/home/data/models/news_model.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetLatestNews {
  final HomeRepository repository;

  GetLatestNews(this.repository);

  Future<List<NewsModel>> call({int limit = 5}) {
    return repository.getLatestNews(limit: limit);
  }
}
