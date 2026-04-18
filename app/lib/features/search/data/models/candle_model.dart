import 'package:egx/features/search/domain/entities/candle_entity.dart';

class CandleModel extends CandleEntity {
  CandleModel({
    super.id,
    required super.candleTime,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
    super.timeframe,
  });

  factory CandleModel.fromJson(Map<String, dynamic> json) {
    return CandleModel(
      id: json['id'],
      candleTime: DateTime.parse(json['candle_time'] ?? json['timestamp']),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: json['volume'] ?? 0,
      timeframe: json['res'] ?? json['timeframe'],
    );
  }
  factory CandleModel.fromBinanceList(List<dynamic> list) {
    return CandleModel(
      candleTime: DateTime.fromMillisecondsSinceEpoch(list[0] as int),
      open: double.parse(list[1].toString()),
      high: double.parse(list[2].toString()),
      low: double.parse(list[3].toString()),
      close: double.parse(list[4].toString()),
      volume: double.parse(list[5].toString()).toInt(),
    );
  }

  CandleEntity toEntity() => this;
}
