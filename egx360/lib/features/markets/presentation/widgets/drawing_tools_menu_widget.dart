import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/presentation/widgets/chart_types.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Drawing settings class to hold color and stroke width
class DrawingSettings {
  final Color color;
  final double strokeWidth;

  const DrawingSettings({
    this.color = const Color(0xFF2196F3),
    this.strokeWidth = 2.0,
  });

  DrawingSettings copyWith({Color? color, double? strokeWidth}) {
    return DrawingSettings(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

/// Available drawing colors
const List<Color> drawingColors = [
  Color(0xFF2196F3), // Blue
  Color(0xFFF44336), // Red
  Color(0xFF4CAF50), // Green
  Color(0xFFFF9800), // Orange
  Color(0xFF9C27B0), // Purple
  Color(0xFF00BCD4), // Cyan
  Color(0xFFFFEB3B), // Yellow
  Color(0xFFFFFFFF), // White
];

/// Available stroke widths
const List<double> strokeWidths = [1.0, 2.0, 3.0, 4.0, 5.0];

/// Widget to display drawing tools menu bottom sheet
class DrawingToolsMenuWidget extends StatefulWidget {
  final DrawingTool selectedTool;
  final bool isDrawing;
  final Color currentColor;
  final double currentStrokeWidth;
  final ValueChanged<DrawingTool> onToolSelected;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final VoidCallback? onClearAllDrawings;

  const DrawingToolsMenuWidget({
    super.key,
    required this.selectedTool,
    required this.isDrawing,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.onToolSelected,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    this.onClearAllDrawings,
  });

  @override
  State<DrawingToolsMenuWidget> createState() => _DrawingToolsMenuWidgetState();
}

class _DrawingToolsMenuWidgetState extends State<DrawingToolsMenuWidget> {
  late Color _selectedColor;
  late double _selectedStrokeWidth;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
    _selectedStrokeWidth = widget.currentStrokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(LucideIcons.pencil, color: context.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                context.s.drawing_tools_title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.onSurface,
                ),
              ),
              const Spacer(),
              if (widget.onClearAllDrawings != null)
                TextButton.icon(
                  onPressed: () {
                    widget.onClearAllDrawings!();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                  label: Text(
                    context.s.drawing_tools_clear_all,
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Drawing Tools Section
          Text(
            context.s.drawing_tools_select_tool,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToolButton(
                context,
                context.s.drawing_tools_line,
                LucideIcons.trendingUp,
                DrawingTool.trendLine,
              ),
              const SizedBox(width: 8),
              _buildToolButton(
                context,
                context.s.drawing_tools_h_line,
                LucideIcons.minus,
                DrawingTool.horizontalLine,
              ),
              const SizedBox(width: 8),
              _buildToolButton(
                context,
                context.s.drawing_tools_v_line,
                LucideIcons.separatorVertical,
                DrawingTool.verticalLine,
              ),
              const SizedBox(width: 8),
              _buildToolButton(
                context,
                context.s.drawing_tools_rect,
                LucideIcons.boxSelect,
                DrawingTool.rectangle,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Color Selection Section
          Text(
            context.s.drawing_tools_color,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: drawingColors.map((color) {
              final isSelected = _selectedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  widget.onColorChanged(color);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color:
                              color == const Color(0xFFFFFFFF) ||
                                  color == const Color(0xFFFFEB3B)
                              ? Colors.black
                              : Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Stroke Width Section
          Text(
            context.s.drawing_tools_width,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: strokeWidths.map((width) {
              final isSelected = _selectedStrokeWidth == width;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStrokeWidth = width);
                  widget.onStrokeWidthChanged(width);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primary.withOpacity(0.2)
                        : context.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? context.primary
                          : context.onSurface.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: width,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(width / 2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${width.toInt()}${context.s.drawing_tools_px}",
                        style: TextStyle(
                          fontSize: 10,
                          color: context.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Preview Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.onSurface.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Text(
                  "${context.s.drawing_tools_preview}:",
                  style: TextStyle(
                    fontSize: 12,
                    color: context.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: _selectedStrokeWidth,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(
                        _selectedStrokeWidth / 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    String label,
    IconData icon,
    DrawingTool tool,
  ) {
    final isSelected = widget.selectedTool == tool && widget.isDrawing;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onToolSelected(tool);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.primary.withOpacity(0.2)
                : context.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? context.primary
                  : context.onSurface.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? context.primary : context.onSurface,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? context.primary : context.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to edit a selected drawing line
class DrawingLineEditorWidget extends StatefulWidget {
  final Color currentColor;
  final double currentStrokeWidth;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  const DrawingLineEditorWidget({
    super.key,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onDelete,
    required this.onDone,
  });

  @override
  State<DrawingLineEditorWidget> createState() =>
      _DrawingLineEditorWidgetState();
}

class _DrawingLineEditorWidgetState extends State<DrawingLineEditorWidget> {
  late Color _selectedColor;
  late double _selectedStrokeWidth;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
    _selectedStrokeWidth = widget.currentStrokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(LucideIcons.edit3, color: context.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                context.s.drawing_tools_edit_title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  widget.onDelete();
                  Navigator.pop(context);
                },
                icon: Icon(LucideIcons.trash2, color: Colors.red.shade400),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Color Selection
          Text(
            context.s.drawing_tools_color,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: drawingColors.map((color) {
              final isSelected = _selectedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  widget.onColorChanged(color);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color:
                              color == const Color(0xFFFFFFFF) ||
                                  color == const Color(0xFFFFEB3B)
                              ? Colors.black
                              : Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Stroke Width Selection
          Text(
            context.s.drawing_tools_width,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: strokeWidths.map((width) {
              final isSelected = _selectedStrokeWidth == width;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStrokeWidth = width);
                  widget.onStrokeWidthChanged(width);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primary.withOpacity(0.2)
                        : context.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? context.primary
                          : context.onSurface.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: width,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(width / 2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${width.toInt()}${context.s.drawing_tools_px}",
                        style: TextStyle(
                          fontSize: 10,
                          color: context.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onDone();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.s.drawing_tools_done,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
