import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';
import 'package:egx/features/news_briefing/domain/repositories/news_briefing_repository.dart';
import 'package:egx/features/news_briefing/data/datasources/news_briefing_remote_data_source.dart';

class NewsBriefingRepositoryImpl implements NewsBriefingRepository {
  final NewsBriefingRemoteDataSource remoteDataSource;

  NewsBriefingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NewsSummaryEntity> summarizeNews({
    required List<NewsEntity> newsItems,
  }) async {
    return await remoteDataSource.summarizeNews(newsItems: newsItems);
  }
}
