import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';
import 'package:egx/features/news_briefing/domain/repositories/news_briefing_repository.dart';

class SummarizeNewsUseCase {
  final NewsBriefingRepository repository;

  SummarizeNewsUseCase(this.repository);

  /// Summarize a list of news items
  ///
  /// Throws an exception if:
  /// - News list is empty
  /// - News list has fewer than 3 items (insufficient for meaningful summary)
  Future<NewsSummaryEntity> call({required List<NewsEntity> newsItems}) async {
    // Validate input
    if (newsItems.isEmpty) {
      throw Exception('No news available to summarize');
    }

    if (newsItems.length < 3) {
      throw Exception(
        'Not enough news to summarize. At least 3 articles are required.',
      );
    }

    // Limit to latest 10 news items
    final newsToSummarize = newsItems.take(10).toList();

    return await repository.summarizeNews(newsItems: newsToSummarize);
  }
}
