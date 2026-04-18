import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:egx/features/markets/presentation/widgets/chart_types.dart';

class ChartToolbar extends StatelessWidget {
  final String selectedTimeframe;
  final List<String> timeframes;
  final Function(String) onTimeframeSelected;
  final bool isDrawing;
  final VoidCallback onToggleDrawing;
  final VoidCallback onShowDrawingTools;
  final int? selectedLineIndex;
  final VoidCallback onDeleteLine;
  final VoidCallback onShowIndicators;
  final ChartType chartType;
  final Function(ChartType) onChartTypeChanged;

  final Color gridColor;

  const ChartToolbar({
    super.key,
    required this.selectedTimeframe,
    required this.timeframes,
    required this.onTimeframeSelected,
    required this.isDrawing,
    required this.onToggleDrawing,
    required this.onShowDrawingTools,
    required this.selectedLineIndex,
    required this.onDeleteLine,
    required this.onShowIndicators,
    required this.chartType,
    required this.onChartTypeChanged,
    required this.gridColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: gridColor, width: 0.5)),
        color: context.background,
      ),
      child: Row(
        children: [
          // Timeframe Selector
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: timeframes.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final timeframe = timeframes[index];
                final isSelected = timeframe == selectedTimeframe;
                return GestureDetector(
                  onTap: () => onTimeframeSelected(timeframe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        timeframe,
                        style: TextStyle(
                          color: isSelected
                              ? context.primary
                              : context.onSurface.withValues(alpha: 0.6),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Drawing Tools Toggle (Reverted to simple button)
          IconButton(
            icon: Icon(
              isDrawing ? LucideIcons.pencil : LucideIcons.pencil,
              color: isDrawing
                  ? context.primary
                  : context.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: isDrawing ? onToggleDrawing : onShowDrawingTools,
          ),

          if (selectedLineIndex != null)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
              onPressed: onDeleteLine,
            ),

          // Indicators
          IconButton(
            icon: Icon(
              LucideIcons.activity,
              color: context.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: onShowIndicators,
          ),

          // Chart Type Selector - Popup Menu
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: context.background,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: context.onSurface.withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            child: PopupMenuButton<ChartType>(
              tooltip: context.s.chart_type_menu_title,
              offset: const Offset(0, 40),
              onSelected: onChartTypeChanged,
              itemBuilder: (context) => [
                _buildChartTypeItem(
                  context,
                  ChartType.candle,
                  context.s.chart_type_candles,
                  LucideIcons.barChart2,
                ),
                _buildChartTypeItem(
                  context,
                  ChartType.bar,
                  context.s.chart_type_bars,
                  LucideIcons.barChart,
                ),
                _buildChartTypeItem(
                  context,
                  ChartType.line,
                  context.s.chart_type_line,
                  LucideIcons.lineChart,
                ),
                _buildChartTypeItem(
                  context,
                  ChartType.heikinAshi,
                  context.s.chart_type_heikin_ashi,
                  LucideIcons.candlestickChart,
                ),
                _buildChartTypeItem(
                  context,
                  ChartType.renko,
                  context.s.chart_type_renko,
                  LucideIcons.component,
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  _getChartTypeIcon(chartType),
                  color: context.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<ChartType> _buildChartTypeItem(
    BuildContext context,
    ChartType type,
    String label,
    IconData icon,
  ) {
    final isSelected = chartType == type;
    return PopupMenuItem<ChartType>(
      value: type,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? context.primary : context.onSurface,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? context.primary : context.onSurface,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check, size: 16, color: context.primary),
          ],
        ],
      ),
    );
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.candle:
        return LucideIcons.barChart2;
      case ChartType.bar:
        return LucideIcons.barChart;
      case ChartType.line:
        return LucideIcons.lineChart;
      case ChartType.heikinAshi:
        return LucideIcons.candlestickChart;
      case ChartType.renko:
        return LucideIcons.component;
    }
  }
}
