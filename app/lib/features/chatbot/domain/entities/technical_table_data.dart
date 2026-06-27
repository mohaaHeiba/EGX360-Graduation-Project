import 'package:freezed_annotation/freezed_annotation.dart';

part 'technical_table_data.freezed.dart';

enum SignalType { bullish, bearish, neutral, loading }

@freezed
abstract class TableRowData with _$TableRowData {
  const TableRowData._();

  const factory TableRowData({
    required String label,
    @Default('...') String value,
    @Default(SignalType.loading) SignalType signal,
  }) = _TableRowData;
}

@freezed
abstract class TechnicalTableData with _$TechnicalTableData {
  const TechnicalTableData._();

  const factory TechnicalTableData({
    required String symbol,
    required Map<String, TableRowData> rows,
  }) = _TechnicalTableData;

  factory TechnicalTableData.empty(String symbol) {
    return TechnicalTableData(
      symbol: symbol,
      rows: {
        'current_price': const TableRowData(label: 'السعر الحالي'),
        'change_1d': const TableRowData(label: 'التغيير (1 يوم)'),
        'ema10': const TableRowData(label: 'EMA10'),
        'ema20': const TableRowData(label: 'EMA20'),
        'ema50': const TableRowData(label: 'EMA50'),
        'sma50': const TableRowData(label: 'SMA50'),
        'sma200': const TableRowData(label: 'SMA200'),
        'rsi14': const TableRowData(label: 'RSI14'),
        'macd': const TableRowData(label: 'MACD'),
        'verdict': const TableRowData(label: 'التوقع العام'),
      },
    );
  }
}
