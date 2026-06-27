import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/chatbot/domain/entities/technical_table_data.dart';
import 'package:flutter/material.dart';

class TechnicalTableWidget extends StatelessWidget {
  final TechnicalTableData table;

  const TechnicalTableWidget({Key? key, required this.table}) : super(key: key);

  Widget _buildSignalIcon(SignalType signal) {
    if (signal == SignalType.bullish) {
      return const Icon(Icons.arrow_upward, color: Colors.green, size: 18);
    } else if (signal == SignalType.bearish) {
      return const Icon(Icons.arrow_downward, color: Colors.red, size: 18);
    } else if (signal == SignalType.loading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      return const Icon(Icons.remove, color: Colors.amber, size: 18);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We force LTR in chat normally, but table internals are Arabic RTL
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.outline.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'مؤشر',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        'قيمة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'إشارة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Rows
            _buildRow(context, table.rows['current_price']!, false),
            _buildRow(context, table.rows['change_1d']!, true),
            _buildRow(context, table.rows['ema10']!, false),
            _buildRow(context, table.rows['ema20']!, true),
            _buildRow(context, table.rows['ema50']!, false),
            _buildRow(context, table.rows['sma50']!, true),
            _buildRow(context, table.rows['sma200']!, false),
            _buildRow(context, table.rows['rsi14']!, true),
            _buildRow(context, table.rows['macd']!, false),

            // Verdict Row
            _buildVerdictRow(context, table.rows['verdict']!),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, TableRowData row, bool isEven) {
    return Container(
      color: isEven ? context.onSurface.withOpacity(0.02) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                row.value,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                ), // Good for numbers
              ),
            ),
          ),
          Expanded(flex: 1, child: Center(child: _buildSignalIcon(row.signal))),
        ],
      ),
    );
  }

  Widget _buildVerdictRow(BuildContext context, TableRowData verdictRow) {
    Color bgColor = context.surface;
    Color textColor = context.onSurface;

    if (verdictRow.signal == SignalType.bullish) {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
    } else if (verdictRow.signal == SignalType.bearish) {
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade700;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            verdictRow.label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          verdictRow.signal == SignalType.loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  verdictRow.value,
                  style: TextStyle(color: textColor, height: 1.4),
                ),
        ],
      ),
    );
  }
}
