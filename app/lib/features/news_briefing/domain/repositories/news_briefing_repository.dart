import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';

abstract class NewsBriefingRepository {
  Future<NewsSummaryEntity> summarizeNews({
    required List<NewsEntity> newsItems,
  });
}
