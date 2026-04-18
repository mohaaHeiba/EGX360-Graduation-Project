import 'package:egx/features/news_briefing/data/datasources/news_briefing_remote_data_source.dart';
import 'package:egx/features/news_briefing/data/repositories/news_briefing_repository_impl.dart';
import 'package:egx/features/news_briefing/domain/usecases/summarize_news_usecase.dart';
import 'package:egx/features/news_briefing/presentation/controllers/news_summary_controller.dart';
import 'package:egx/core/services/cerebras_ai_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NewsBriefingBindings extends Bindings {
  @override
  void dependencies() {
    // AI Service
    final cerebrasAiService = CerebrasAiService(client: http.Client());

    // Data Source
    final newsBriefingRemoteDataSource = NewsBriefingRemoteDataSourceImpl(
      cerebrasService: cerebrasAiService,
    );

    // Repository
    final newsBriefingRepository = NewsBriefingRepositoryImpl(
      remoteDataSource: newsBriefingRemoteDataSource,
    );

    // Use Case
    final summarizeNewsUseCase = SummarizeNewsUseCase(newsBriefingRepository);

    // Put use case in Get for potential future use
    Get.put(summarizeNewsUseCase);

    // Controller
    Get.put(NewsSummaryController());
  }
}
