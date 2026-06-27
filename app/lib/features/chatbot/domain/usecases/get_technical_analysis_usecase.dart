import 'package:egx/features/chatbot/domain/entities/technical_table_data.dart';
import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Retrieves a fully hydrated [TechnicalTableData] for a given stock symbol.
/// All three data stages (price, technicals, verdict) are resolved inside
/// [ChatbotRepository.getTechnicalAnalysis], keeping this use-case thin.
class GetTechnicalAnalysisUseCase {
  final ChatbotRepository repository;

  GetTechnicalAnalysisUseCase(this.repository);

  Future<TechnicalTableData?> call(String symbol) async {
    return repository.getTechnicalAnalysis(symbol);
  }
}
