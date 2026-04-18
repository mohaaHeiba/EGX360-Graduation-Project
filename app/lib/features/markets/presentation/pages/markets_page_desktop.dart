import 'dart:math';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/markets/presentation/utils/chart_formatters.dart';
import 'package:egx/features/markets/presentation/widgets/chart_header.dart';
import 'package:egx/features/markets/presentation/widgets/chart_toolbar.dart';
import 'package:egx/features/markets/presentation/widgets/chart_types.dart';
import 'package:egx/features/markets/presentation/widgets/chart_view.dart';
import 'package:egx/features/markets/presentation/widgets/desktop/markets_right_sidebar.dart';
import 'package:egx/features/markets/presentation/widgets/drawing_tools_menu_widget.dart';
import 'package:egx/features/markets/presentation/widgets/indicators_menu_widget.dart';
import 'package:egx/features/markets/presentation/widgets/markets_chart_shimmer.dart';
import 'package:egx/features/markets/presentation/widgets/order_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MarketsPageDesktop extends StatefulWidget {
  const MarketsPageDesktop({super.key});

  @override
  State<MarketsPageDesktop> createState() => _MarketsPageDesktopState();
}

class _MarketsPageDesktopState extends State<MarketsPageDesktop> {
  final MarketsController controller = Get.put(MarketsController());
  late TrackballBehavior _trackballBehavior;
  // <--- ضيف السطر ده
  ChartType _chartType = ChartType.candle;
  String _selectedTimeframe = '1m';
  final List<String> _timeframes = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1H',
    '4H',
    '1D',
    '1W',
    '1M',
  ];

  // Indicator Configurations
  IndicatorConfig _smaConfig = const IndicatorConfig(period: 14);
  IndicatorConfig _emaConfig = const IndicatorConfig(period: 14);
  IndicatorConfig _bollingerConfig = const IndicatorConfig(
    period: 20,
    standardDeviation: 2,
  );
  IndicatorConfig _rsiConfig = const IndicatorConfig(period: 14);
  bool _showVolume = true;

  // Drawing State
  bool _isDrawing = false;
  final List<TrendLine> _trendLines = [];
  ChartSeriesController? _seriesController;
  Offset? _startPoint;
  Offset? _endPoint;
  int? _selectedLineIndex;
  DrawingTool _selectedTool = DrawingTool.trendLine;
  Color _drawingColor = const Color(0xFF2196F3);
  double _drawingStrokeWidth = 2.0;
  bool _isSidebarVisible = true;

  // Dragging State (for mouse interactions)
  bool _isDraggingLine = false;
  Offset? _dragStartOffset;
  int? _draggingHandle; // 0 = start, 1 = end, null = whole line
  int _estimatedVisibleCandles = 50;

  @override
  void initState() {
    super.initState();

    // Trackball القديم بتاعك
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(enable: true),
      lineType: TrackballLineType.vertical,
    );

    // --- ضيف تعريف الزوم هنا ---
  }

  // NOTE: Reusing helper methods from mobile page logic where applicable
  // Ideally these should be in the controller or a shared mixin
  // For now duplicating minimal state logic required for the chart widget

  DateFormat? _dynamicDateFormat;

  // Methods for sheets/dialogs (adapted for desktop if needed, or reused mobile sheets)
  void _showOrderSheet(BuildContext context, {required bool isBuy}) {
    // Reuse mobile sheet
    final selectedStock = controller.selectedStock.value;
    if (selectedStock == null) return;

    final currentPrice = controller.candles.isNotEmpty
        ? controller.candles.last.close
        : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: OrderSheet(
            isBuy: isBuy,
            symbol: selectedStock.symbol,
            currentPrice: currentPrice,
          ),
        );
      },
    );
  }

  void _showIndicatorsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: IndicatorsMenuWidget(
                smaConfig: _smaConfig,
                emaConfig: _emaConfig,
                bollingerConfig: _bollingerConfig,
                rsiConfig: _rsiConfig,
                showVolume: _showVolume,
                onSMAChanged: (config) {
                  setModalState(() => _smaConfig = config);
                  setState(() {});
                },
                onEMAChanged: (config) {
                  setModalState(() => _emaConfig = config);
                  setState(() {});
                },
                onBollingerChanged: (config) {
                  setModalState(() => _bollingerConfig = config);
                  setState(() {});
                },
                onRSIChanged: (config) {
                  setModalState(() => _rsiConfig = config);
                  setState(() {});
                },
                onVolumeChanged: (value) {
                  setModalState(() => _showVolume = value);
                  setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showDrawingToolsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DrawingToolsMenuWidget(
              selectedTool: _selectedTool,
              isDrawing: _isDrawing,
              currentColor: _drawingColor,
              currentStrokeWidth: _drawingStrokeWidth,
              onToolSelected: (tool) {
                setState(() {
                  _selectedTool = tool;
                  _isDrawing = true;
                  _selectedLineIndex = null;
                });
              },
              onColorChanged: (color) {
                setModalState(() {});
                setState(() => _drawingColor = color);
              },
              onStrokeWidthChanged: (width) {
                setModalState(() {});
                setState(() => _drawingStrokeWidth = width);
              },
              onClearAllDrawings: () {
                setState(() {
                  _trendLines.clear();
                  _selectedLineIndex = null;
                });
              },
            );
          },
        );
      },
    );
  }

  void _showLineEditorSheet(BuildContext context, int lineIndex) {
    final line = _trendLines[lineIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DrawingLineEditorWidget(
          currentColor: line.color,
          currentStrokeWidth: line.strokeWidth,
          onColorChanged: (color) {
            setState(() {
              _trendLines[lineIndex] = line.copyWith(color: color);
            });
          },
          onStrokeWidthChanged: (width) {
            setState(() {
              _trendLines[lineIndex] = line.copyWith(strokeWidth: width);
            });
          },
          onDelete: () {
            setState(() {
              _trendLines.removeAt(lineIndex);
              _selectedLineIndex = null;
            });
          },
          onDone: () {
            setState(() => _selectedLineIndex = null);
          },
        );
      },
    );
  }

  double _distanceToSegment(Offset p, Offset p1, Offset p2) {
    final double l2 = (p1 - p2).distanceSquared;
    if (l2 == 0) return (p - p1).distance;
    double t =
        ((p.dx - p1.dx) * (p2.dx - p1.dx) + (p.dy - p1.dy) * (p2.dy - p1.dy)) /
        l2;
    t = max(0, min(1, t));
    final Offset projection = Offset(
      p1.dx + t * (p2.dx - p1.dx),
      p1.dy + t * (p2.dy - p1.dy),
    );
    return (p - projection).distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        children: [
          // Left: Chart Area
          Expanded(
            flex: 3,
            child: Obx(() {
              final gridColor = context.isDark
                  ? AppColors.gridLine
                  : Colors.grey.shade300;

              if (controller.isLoadingCandles.value) {
                return Column(
                  children: [
                    ChartHeader(
                      price: 0,
                      change: 0,
                      percent: 0,
                      color: context.onSurface,
                      gridColor: gridColor,
                      selectedTimeframe: _selectedTimeframe,
                      timeframes: _timeframes,
                      onTimeframeSelected: (value) {
                        setState(() {
                          _selectedTimeframe = value;
                        });
                        controller.selectedInterval.value = value;
                        if (controller.selectedStock.value != null) {
                          controller.fetchCandles(
                            controller.selectedStock.value!,
                            interval: value,
                          );
                        }
                      },
                      controller: controller,
                      onToggleSidebar: () {
                        setState(() {
                          _isSidebarVisible = !_isSidebarVisible;
                        });
                      },
                      enableSearch: false,
                    ),
                    const Expanded(child: MarketsChartShimmer()),
                  ],
                );
              }

              // Data mapping
              List<ChartData> currentData = [];
              if (controller.candles.isNotEmpty) {
                var index = 0;
                currentData = controller.candles
                    .map(
                      (e) => ChartData(
                        index: index++,
                        x: e.candleTime,
                        open: e.open,
                        high: e.high,
                        low: e.low,
                        close: e.close,
                        volume: e.volume.toDouble(),
                      ),
                    )
                    .toList();
              }

              if (currentData.isEmpty) {
                return Center(
                  child: Text(
                    context.s.markets_select_asset,
                    style: TextStyle(color: context.onSurface),
                  ),
                );
              }

              final lastCandle = currentData.last;
              final firstCandle = currentData.first;
              double priceChange;
              double percentChange;
              final currentPrice = lastCandle.close;
              final prevClose = controller.selectedStock.value?.prevClose;

              if (prevClose != null && prevClose > 0) {
                priceChange = currentPrice - prevClose;
                percentChange = (priceChange / prevClose) * 100;
              } else {
                priceChange = currentPrice - firstCandle.open;
                percentChange = (priceChange / firstCandle.open) * 100;
              }
              final isPositive = priceChange >= 0;
              final color = isPositive
                  ? AppColors.candleGreen
                  : AppColors.candleRed;

              return Column(
                children: [
                  ChartHeader(
                    price: lastCandle.close,
                    change: priceChange,
                    percent: percentChange,
                    color: color,
                    gridColor: gridColor,
                    selectedTimeframe: _selectedTimeframe,
                    timeframes: _timeframes,
                    onTimeframeSelected: (value) {
                      setState(() {
                        _selectedTimeframe = value;
                        _dynamicDateFormat = null;
                      });
                      if (controller.selectedStock.value != null) {
                        controller.fetchCandles(
                          controller.selectedStock.value!,
                          interval: value,
                        );
                      }
                    },
                    controller: controller,
                    onToggleSidebar: () {
                      setState(() {
                        _isSidebarVisible = !_isSidebarVisible;
                      });
                    },
                    enableSearch: false,
                  ),

                  // Toolbar
                  ChartToolbar(
                    selectedTimeframe: _selectedTimeframe,
                    timeframes: _timeframes,
                    onTimeframeSelected: (String value) {
                      setState(() {
                        _selectedTimeframe = value;
                      });
                      controller.selectedInterval.value = value;
                      if (controller.selectedStock.value != null) {
                        controller.fetchCandles(
                          controller.selectedStock.value!,
                          interval: value,
                        );
                      }
                    },
                    isDrawing: _isDrawing,
                    onToggleDrawing: () {
                      setState(() {
                        // If drawing, toggle off
                        if (_isDrawing) {
                          _isDrawing = false;
                          _selectedLineIndex = null;
                        } else {
                          // If not drawing, default to last tool or trendline
                          _isDrawing = true;
                        }
                      });
                    },
                    onShowDrawingTools: () => _showDrawingToolsMenu(context),

                    selectedLineIndex: _selectedLineIndex,
                    onDeleteLine: () {
                      if (_selectedLineIndex != null) {
                        setState(() {
                          _trendLines.removeAt(_selectedLineIndex!);
                          _selectedLineIndex = null;
                        });
                      }
                    },
                    onShowIndicators: () => _showIndicatorsMenu(context),
                    chartType: _chartType,
                    onChartTypeChanged: (type) {
                      setState(() {
                        _chartType = type;
                      });
                    },
                    gridColor: gridColor,
                  ),

                  Expanded(
                    child: ChartView(
                      controller: controller,
                      selectedTimeframe: _selectedTimeframe,
                      dynamicDateFormat: _dynamicDateFormat,
                      chartType: _chartType,
                      smaConfig: _smaConfig,
                      emaConfig: _emaConfig,
                      bollingerConfig: _bollingerConfig,
                      rsiConfig: _rsiConfig,
                      showVolume: _showVolume,
                      isDrawing: _isDrawing,
                      trendLines: _trendLines,
                      startPoint: _startPoint,
                      endPoint: _endPoint,
                      selectedLineIndex: _selectedLineIndex,
                      selectedTool: _selectedTool,
                      drawingColor: _drawingColor,
                      drawingStrokeWidth: _drawingStrokeWidth,
                      trackballBehavior: _trackballBehavior,
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enablePanning: true,
                        enableDoubleTapZooming: true,
                        zoomMode: ZoomMode.x,
                        maximumZoomLevel: 0.01,
                        enableMouseWheelZooming: true,
                        enableSelectionZooming: true,
                      ),
                      gridColor: gridColor,
                      getDateFormat: ChartFormatters.getDateFormat,
                      getIntervalType: ChartFormatters.getIntervalType,
                      dayPlotBands: ChartFormatters.getDayPlotBands(
                        currentData,
                        _selectedTimeframe,
                        context,
                      ),
                      getIntervalDuration: ChartFormatters.getIntervalDuration,
                      showOrderSheet: _showOrderSheet,
                      onRendererCreated: (controller) {
                        _seriesController = controller;
                      },
                      seriesController: _seriesController,
                      onActualRangeChanged: (ActualRangeChangedArgs args) {
                        // التأكد من أن التغيير يحدث على محور الوقت (X-Axis)
                        if (args.axisName == 'primaryXAxis') {
                          // --- قمنا بحذف منطق التقييد من هنا لمنع الـ Loop ---

                          if (controller.candles.isNotEmpty) {
                            final visibleMin = args.visibleMin as num;
                            final visibleMax = args.visibleMax as num;
                            final rangeDuration = visibleMax - visibleMin;

                            // الحصول على مدة الشمعة بالمللي ثانية
                            final intervalMs =
                                ChartFormatters.getIntervalDuration(
                                  _selectedTimeframe,
                                ).inMilliseconds;

                            // 1. تحديث عدد الشموع المتوقعة
                            final estimated = (rangeDuration / intervalMs)
                                .ceil();
                            if (estimated != _estimatedVisibleCandles) {
                              _estimatedVisibleCandles = estimated.clamp(
                                0,
                                10000,
                              );
                            }

                            // 2. منطق تنسيق التاريخ (كما هو)
                            String newPattern;
                            if (['1D', '1W'].contains(_selectedTimeframe)) {
                              newPattern = 'd MMM';
                            } else if ([
                              '1M',
                              '6M',
                              '1Y',
                            ].contains(_selectedTimeframe)) {
                              newPattern = 'MMM yyyy';
                            } else if (rangeDuration > 31536000000) {
                              newPattern = 'yyyy';
                            } else if (rangeDuration > 2592000000) {
                              newPattern = 'MMM yyyy';
                            } else if (rangeDuration > 259200000) {
                              newPattern = 'd MMM';
                            } else if (rangeDuration > 86400000) {
                              newPattern = 'd MMM\nHH:mm';
                            } else {
                              newPattern = 'HH:mm';
                            }

                            if (_dynamicDateFormat?.pattern != newPattern) {
                              Future.microtask(() {
                                if (mounted) {
                                  setState(() {
                                    _dynamicDateFormat = DateFormat(newPattern);
                                  });
                                }
                              });
                            }
                          }
                        }
                      },
                      onZooming: (ZoomPanArgs args) {
                        // 1. طباعة اسم المحور عشان نتأكد إنه بيقرا الـ X Axis
                        print("🔍 Zooming on Axis: ${args.axis?.name}");

                        // 2. طباعة قيمة الزوم الحالية (قبل التعديل)
                        // القيمة دي بتبقى من 1.0 (زوم كامل 0%) لحد 0.0 (زوم قوي جداً)
                        // كل ما الرقم يقرب لـ 1.0 معناه إنك بتعمل Zoom Out (بتشوف داتا أكتر)
                        print(
                          "📊 Current Zoom Factor: ${args.currentZoomFactor}",
                        );

                        // 3. طباعة الاتجاه (اختياري)
                        print(
                          "------------------------------------------------",
                        );

                        // الكود بتاعنا (مؤقتاً خليه كومنت لحد ما نشوف الأرقام)
                        if (args.currentZoomFactor > 0.8) {
                          // هنا فقط نلغي العملية ونعيدها للقيمة السابقة أو نثبتها عند الحد الأقصى
                          args.currentZoomFactor = 0.8;
                        }

                        // مثال: منع التكبير الزائد (قيمة صغيرة جداً)
                        if (args.currentZoomFactor < 0.1) {
                          args.currentZoomFactor = 0.1;
                        }
                      },
                      onChartTouchInteractionDown: (args) {
                        if (_isDrawing) {
                          setState(() {
                            _startPoint = args.position;
                            _endPoint = args.position;
                          });
                        } else if (_selectedLineIndex != null &&
                            _seriesController != null) {
                          // Check if touching a handle or the line body
                          final line = _trendLines[_selectedLineIndex!];
                          final startPixel = _seriesController!.pointToPixel(
                            line.start,
                          );
                          final endPixel = _seriesController!.pointToPixel(
                            line.end,
                          );
                          final touchPos = args.position;
                          const handleRadius = 15.0; // Touch area for handles

                          // Check start handle
                          if ((touchPos - startPixel).distance < handleRadius) {
                            setState(() {
                              _isDraggingLine = true;
                              _draggingHandle = 0; // Start handle
                              _dragStartOffset = args.position;
                            });
                          }
                          // Check end handle
                          else if ((touchPos - endPixel).distance <
                              handleRadius) {
                            setState(() {
                              _isDraggingLine = true;
                              _draggingHandle = 1; // End handle
                              _dragStartOffset = args.position;
                            });
                          }
                          // Check if touch is on line body
                          else {
                            double dist = double.infinity;
                            if (line.type == DrawingTool.horizontalLine) {
                              dist = (touchPos.dy - startPixel.dy).abs();
                            } else if (line.type == DrawingTool.verticalLine) {
                              dist = (touchPos.dx - startPixel.dx).abs();
                            } else if (line.type == DrawingTool.rectangle) {
                              final rect = Rect.fromPoints(
                                startPixel,
                                endPixel,
                              );
                              if (rect.contains(touchPos)) {
                                dist = 0;
                              }
                            } else {
                              dist = _distanceToSegment(
                                touchPos,
                                startPixel,
                                endPixel,
                              );
                            }

                            // Only start dragging if actually on the line (within 20px)
                            if (dist < 20.0) {
                              setState(() {
                                _isDraggingLine = true;
                                _draggingHandle = null; // Whole line
                                _dragStartOffset = args.position;
                              });
                            }
                          }
                        }
                      },
                      onChartTouchInteractionMove: (args) {
                        if (_isDrawing && _startPoint != null) {
                          setState(() {
                            _endPoint = args.position;
                          });
                        } else if (_isDraggingLine &&
                            _selectedLineIndex != null &&
                            _dragStartOffset != null &&
                            _seriesController != null) {
                          final currentPos = args.position;
                          final line = _trendLines[_selectedLineIndex!];

                          if (_draggingHandle == 0) {
                            // Dragging start handle only
                            final newStart = _seriesController!.pixelToPoint(
                              currentPos,
                            );
                            setState(() {
                              _trendLines[_selectedLineIndex!] = line.copyWith(
                                start: newStart,
                              );
                              _dragStartOffset = currentPos;
                            });
                          } else if (_draggingHandle == 1) {
                            // Dragging end handle only
                            final newEnd = _seriesController!.pixelToPoint(
                              currentPos,
                            );
                            setState(() {
                              _trendLines[_selectedLineIndex!] = line.copyWith(
                                end: newEnd,
                              );
                              _dragStartOffset = currentPos;
                            });
                          } else {
                            // Dragging whole line
                            final delta = currentPos - _dragStartOffset!;
                            final startPixel = _seriesController!.pointToPixel(
                              line.start,
                            );
                            final endPixel = _seriesController!.pointToPixel(
                              line.end,
                            );

                            final newStartPixel = startPixel + delta;
                            final newEndPixel = endPixel + delta;

                            final newStart = _seriesController!.pixelToPoint(
                              newStartPixel,
                            );
                            final newEnd = _seriesController!.pixelToPoint(
                              newEndPixel,
                            );

                            setState(() {
                              _trendLines[_selectedLineIndex!] = line.copyWith(
                                start: newStart,
                                end: newEnd,
                              );
                              _dragStartOffset = currentPos;
                            });
                          }
                        }
                      },
                      onChartTouchInteractionUp: (args) {
                        if (_isDraggingLine) {
                          // End drag
                          setState(() {
                            _isDraggingLine = false;
                            _dragStartOffset = null;
                            _draggingHandle = null;
                          });
                          return;
                        }

                        if (_isDrawing) {
                          if (_startPoint == null ||
                              _seriesController == null) {
                            return;
                          }

                          final start = _seriesController!.pixelToPoint(
                            _startPoint!,
                          );
                          final end = _seriesController!.pixelToPoint(
                            args.position,
                          );

                          setState(() {
                            _trendLines.add(
                              TrendLine(
                                start,
                                end,
                                _selectedTool,
                                color: _drawingColor,
                                strokeWidth: _drawingStrokeWidth,
                              ),
                            );
                            _startPoint = null;
                            _endPoint = null;
                          });
                        } else {
                          // Handle Selection
                          if (_seriesController == null) return;
                          final touchPos = args.position;
                          int? newSelection;
                          double minDistance = 30.0; // Hit test radius

                          for (int i = 0; i < _trendLines.length; i++) {
                            final line = _trendLines[i];
                            final p1 = _seriesController!.pointToPixel(
                              line.start,
                            );
                            final p2 = _seriesController!.pointToPixel(
                              line.end,
                            );

                            double dist = double.infinity;
                            if (line.type == DrawingTool.horizontalLine) {
                              dist = (touchPos.dy - p1.dy).abs();
                            } else if (line.type == DrawingTool.verticalLine) {
                              dist = (touchPos.dx - p1.dx).abs();
                            } else if (line.type == DrawingTool.rectangle) {
                              final rect = Rect.fromPoints(p1, p2);
                              if (rect.contains(touchPos)) {
                                dist = 0;
                              } else {
                                dist = _distanceToSegment(touchPos, p1, p2);
                              }
                            } else {
                              dist = _distanceToSegment(touchPos, p1, p2);
                            }

                            if (dist < minDistance) {
                              minDistance = dist;
                              newSelection = i;
                            }
                          }

                          setState(() {
                            if (newSelection != null &&
                                _selectedLineIndex == newSelection) {
                              // Double-tap on same line opens editor
                              _showLineEditorSheet(context, newSelection);
                            }
                            _selectedLineIndex = newSelection;
                          });
                        }
                      },
                    ),
                  ),
                ],
              );
            }),
          ),

          // Right: Asset Sidebar
          if (_isSidebarVisible)
            const Expanded(flex: 1, child: MarketsRightSidebar()),
        ],
      ),
    );
  }
}
