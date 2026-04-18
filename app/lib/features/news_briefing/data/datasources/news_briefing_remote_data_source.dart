import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';
import 'package:egx/features/news_briefing/data/config/news_summarization_prompts.dart';
import 'package:egx/core/services/cerebras_ai_service.dart';
import 'package:get_storage/get_storage.dart';

abstract class NewsBriefingRemoteDataSource {
  Future<NewsSummaryEntity> summarizeNews({
    required List<NewsEntity> newsItems,
  });
}

class NewsBriefingRemoteDataSourceImpl implements NewsBriefingRemoteDataSource {
  final CerebrasAiService cerebrasService;
  final GetStorage _storage = GetStorage();

  NewsBriefingRemoteDataSourceImpl({required this.cerebrasService});

  /// Split news into chunks based on character limit
  List<List<Map<String, String>>> _chunkNews(
    List<Map<String, String>> newsForPrompt,
    int maxCharsPerChunk,
  ) {
    List<List<Map<String, String>>> chunks = [];
    List<Map<String, String>> currentChunk = [];
    int currentChunkSize = 0;

    for (var news in newsForPrompt) {
      final newsText = cerebrasService.formatNewsForPrompt([news]);
      final newsSize = newsText.length;

      // If adding this news exceeds limit, start new chunk
      if (currentChunkSize + newsSize > maxCharsPerChunk &&
          currentChunk.isNotEmpty) {
        chunks.add(List.from(currentChunk));
        currentChunk = [];
        currentChunkSize = 0;
      }

      currentChunk.add(news);
      currentChunkSize += newsSize;
    }

    // Add remaining chunk
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks;
  }

  /// Summarize a single chunk of news
  Future<String> _summarizeChunk(
    List<Map<String, String>> chunk,
    Map<String, String> prompts,
  ) async {
    final formattedChunk = cerebrasService.formatNewsForPrompt(chunk);

    return await cerebrasService.generateCompletion(
      content: formattedChunk,
      systemPrompt: prompts['systemPrompt']!,
      userPrompt: prompts['userPrompt']!,
      temperature: NewsSummarizationPrompts.temperature,
      maxTokens: NewsSummarizationPrompts.maxTokens,
    );
  }

  /// Merge multiple summaries into one cohesive summary
  Future<String> _mergeSummaries(
    List<String> summaries,
    Map<String, String> prompts,
  ) async {
    if (summaries.length == 1) {
      return summaries.first;
    }

    // Create a prompt to merge the summaries
    final mergeSystemPrompt = prompts['systemPrompt']!;
    final mergeUserPrompt = prompts['systemPrompt']!.contains('أنت')
        ? 'قم بدمج هذه الملخصات المتعددة في ملخص واحد متماسك وشامل:'
        : 'Merge these multiple summaries into one cohesive, comprehensive summary:';

    final combinedSummaries = summaries
        .asMap()
        .entries
        .map((entry) => 'Summary ${entry.key + 1}:\n${entry.value}')
        .join('\n\n');

    return await cerebrasService.generateCompletion(
      content: combinedSummaries,
      systemPrompt: mergeSystemPrompt,
      userPrompt: mergeUserPrompt,
      temperature: NewsSummarizationPrompts.temperature,
      maxTokens: NewsSummarizationPrompts.maxTokens,
    );
  }

  @override
  Future<NewsSummaryEntity> summarizeNews({
    required List<NewsEntity> newsItems,
  }) async {
    try {
      // Format news items for the AI
      final newsForPrompt = newsItems
          .map((news) {
            return {
              'title': news.title,
              'content': news.content ?? '',
              'publishedAt': news.publishedAt,
            };
          })
          .toList()
          .cast<Map<String, String>>();

      final totalLength = cerebrasService
          .formatNewsForPrompt(newsForPrompt)
          .length;

      print('📰 Summarizing ${newsItems.length} news articles...');
      print('📝 Total content length: $totalLength characters');

      // Get saved language preference from settings
      final savedLanguage = _storage.read('savedLanguage') ?? 'English';
      final isArabic = savedLanguage == 'arabic';

      print('🌐 Using saved language: ${isArabic ? "Arabic" : "English"}');

      // Get appropriate prompts based on saved language
      final prompts = isArabic
          ? {
              'systemPrompt': NewsSummarizationPrompts.systemPromptArabic,
              'userPrompt': NewsSummarizationPrompts.userPromptArabic,
            }
          : {
              'systemPrompt': NewsSummarizationPrompts.systemPromptEnglish,
              'userPrompt': NewsSummarizationPrompts.userPromptEnglish,
            };

      String finalSummary;

      // Check if we need to split into chunks
      if (totalLength > NewsSummarizationPrompts.maxInputCharacters) {
        print('📦 Content too large, splitting into chunks...');

        // Split news into chunks
        final chunks = _chunkNews(
          newsForPrompt,
          NewsSummarizationPrompts.maxInputCharacters,
        );

        print('✂️ Split into ${chunks.length} chunks');

        // Summarize all chunks in parallel using Future.wait
        print('⚡ Processing chunks in parallel...');
        final chunkSummaries = await Future.wait(
          chunks.map((chunk) => _summarizeChunk(chunk, prompts)),
        );

        print('✅ All chunks summarized, merging...');

        // Merge all summaries
        finalSummary = await _mergeSummaries(chunkSummaries, prompts);

        print('🎯 Final merged summary created!');
      } else {
        // Content fits in one request, summarize directly
        print('✅ Content fits in single request');
        final formattedNews = cerebrasService.formatNewsForPrompt(
          newsForPrompt,
        );

        finalSummary = await cerebrasService.generateCompletion(
          content: formattedNews,
          systemPrompt: prompts['systemPrompt']!,
          userPrompt: prompts['userPrompt']!,
          temperature: NewsSummarizationPrompts.temperature,
          maxTokens: NewsSummarizationPrompts.maxTokens,
        );
      }

      // Extract date range
      DateTime? oldestDate;
      DateTime? newestDate;

      for (var news in newsItems) {
        try {
          final date = DateTime.parse(news.publishedAt);
          if (oldestDate == null || date.isBefore(oldestDate)) {
            oldestDate = date;
          }
          if (newestDate == null || date.isAfter(newestDate)) {
            newestDate = date;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }

      return NewsSummaryEntity(
        summary: finalSummary,
        newsCount: newsItems.length,
        oldestNewsDate: oldestDate,
        newestNewsDate: newestDate,
        newsIds: newsItems.map((n) => n.id).toList(),
      );
    } catch (e) {
      throw Exception('Failed to summarize news: $e');
    }
  }
}
