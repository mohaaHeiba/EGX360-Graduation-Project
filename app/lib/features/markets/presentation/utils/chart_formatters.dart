import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:egx/features/markets/presentation/widgets/chart_view.dart';

/// Utility class for chart date formatting and interval calculations
class ChartFormatters {
  ChartFormatters._();

  /// Get the appropriate date format based on the selected interval
  static DateFormat getDateFormat(String interval) {
    switch (interval) {
      case '1m':
      case '5m':
      case '15m':
      case '30m':
      case '1H':
      case '4H':
        return DateFormat('HH:mm');
      case '1D':
      case '1W':
        return DateFormat('d MMM');
      case '1M':
      case '6M':
      case '1Y':
        return DateFormat('MMM yyyy');
      default:
        return DateFormat('d MMM');
    }
  }

  /// Get the interval type for date-time axis
  static DateTimeIntervalType getIntervalType(String interval) {
    switch (interval) {
      case '1m':
      case '5m':
      case '15m':
      case '30m':
        return DateTimeIntervalType.minutes;
      case '1H':
      case '4H':
        return DateTimeIntervalType.hours;
      case '1D':
      case '1W':
        return DateTimeIntervalType.days;
      case '1M':
      case '6M':
      case '1Y':
        return DateTimeIntervalType.months;
      default:
        return DateTimeIntervalType.days;
    }
  }

  /// Get the duration for a given interval
  static Duration getIntervalDuration(String interval) {
    switch (interval) {
      case '1m':
        return const Duration(minutes: 1);
      case '5m':
        return const Duration(minutes: 5);
      case '15m':
        return const Duration(minutes: 15);
      case '30m':
        return const Duration(minutes: 30);
      case '1H':
        return const Duration(hours: 1);
      case '4H':
        return const Duration(hours: 4);
      case '1D':
        return const Duration(days: 1);
      case '1W':
        return const Duration(days: 7);
      case '1M':
        return const Duration(days: 30);
      default:
        return const Duration(days: 1);
    }
  }

  /// Generate day separator plot bands for intraday intervals
  static List<PlotBand> getDayPlotBands(
    List<ChartData> data,
    String selectedTimeframe,
    BuildContext context,
  ) {
    if (data.isEmpty ||
        !['1m', '5m', '15m', '30m', '1H'].contains(selectedTimeframe)) {
      return [];
    }

    final List<PlotBand> plotBands = [];
    DateTime? lastDay;

    for (var i = 0; i < data.length; i++) {
      final currentDay = DateTime(
        data[i].x.year,
        data[i].x.month,
        data[i].x.day,
      );

      if (lastDay != null && currentDay != lastDay) {
        // Add a plot band at the start of each new day
        plotBands.add(
          PlotBand(
            start: data[i].x,
            end: data[i].x,
            borderWidth: 1,
            borderColor: context.onSurface.withValues(alpha: 0.2),
            associatedAxisStart: data[i].x,
            associatedAxisEnd: data[i].x,
          ),
        );
      }
      lastDay = currentDay;
    }

    return plotBands;
  }

  /// Get dynamic date format based on visible range duration
  static DateFormat getDynamicDateFormat(
    double rangeDuration,
    String selectedTimeframe,
  ) {
    String pattern;

    // For historical intervals (1D, 1W, 1M), always show dates, never times
    if (['1D', '1W'].contains(selectedTimeframe)) {
      pattern = 'd MMM';
    } else if (['1M', '6M', '1Y'].contains(selectedTimeframe)) {
      pattern = 'MMM yyyy';
    } else if (rangeDuration > 31536000000) {
      // > 1 Year
      pattern = 'yyyy';
    } else if (rangeDuration > 2592000000) {
      // > 1 Month
      pattern = 'MMM yyyy';
    } else if (rangeDuration > 259200000) {
      // > 3 Days
      pattern = 'd MMM';
    } else if (rangeDuration > 86400000) {
      // > 1 Day (multi-day intraday view)
      pattern = 'd MMM\nHH:mm';
    } else {
      // < 1 Day (single day intraday)
      pattern = 'HH:mm';
    }

    return DateFormat(pattern);
  }
}
