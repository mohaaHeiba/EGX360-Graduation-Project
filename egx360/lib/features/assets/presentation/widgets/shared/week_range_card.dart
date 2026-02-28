import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';

/// A custom card that displays 52-week range with a linear visualization
class WeekRangeCard extends StatelessWidget {
  final double? lowValue;
  final double? highValue;
  final double? currentValue;
  final String lowLabel;
  final String highLabel;

  const WeekRangeCard({
    super.key,
    required this.lowValue,
    required this.highValue,
    required this.currentValue,
    required this.lowLabel,
    required this.highLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate position percentage (0.0 to 1.0)
    double? positionPercent;
    Color indicatorColor = context.primary;

    if (lowValue != null && highValue != null && currentValue != null) {
      if (highValue! > lowValue!) {
        positionPercent =
            (currentValue! - lowValue!) / (highValue! - lowValue!);
        positionPercent = positionPercent.clamp(0.0, 1.0);

        // Color based on position: red if in lower half, green if in upper half
        if (positionPercent < 0.5) {
          indicatorColor = Colors.redAccent;
        } else {
          indicatorColor = Colors.greenAccent;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? context.surface.withOpacity(0.5) : context.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  size: 14,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "52-Week Range",
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear visualization bar
          if (positionPercent != null) ...[
            Stack(
              children: [
                // Background bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Progress bar (from low to current)
                FractionallySizedBox(
                  widthFactor: positionPercent,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent.withOpacity(0.7),
                          indicatorColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Current price indicator
                FractionallySizedBox(
                  widthFactor: positionPercent,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: indicatorColor.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Low and High labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Low",
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.onSurface.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lowLabel,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "High",
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.onSurface.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    highLabel,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
