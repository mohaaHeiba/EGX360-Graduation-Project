import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetLatestAiPredictionUseCase {
  final SearchRepository repository;

  GetLatestAiPredictionUseCase(this.repository);

  Future<AiPrediction?> call(String symbol) async {
    return await repository.getLatestAiPrediction(symbol);
  }
}
