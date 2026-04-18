import 'package:egx/features/markets/domain/entities/ai_prediction.dart';

class AiPredictionModel extends AiPrediction {
  const AiPredictionModel({
    required super.symbol,
    required super.closePrice,
    required super.probability,
    required super.createdAt,
  });

  factory AiPredictionModel.fromMap(Map<String, dynamic> map) {
    return AiPredictionModel(
      symbol: map['symbol'] as String,
      closePrice: (map['close_price'] as num).toDouble(),
      probability: (map['probability'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'close_price': closePrice,
      'probability': probability,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
