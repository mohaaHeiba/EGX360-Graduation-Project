import 'dart:math' as math;
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/services/technical_result.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';

/// Technical analysis gauge showing buy/sell signals with indicator breakdown.
/// Value range: -100 (strong sell) to +100 (strong buy)
class TechnicalGauge extends StatelessWidget {
  final double value; // -100 to +100
  final TechnicalResult? result;
  final VoidCallback? onMoreTap;
  final bool display;
  final bool isAi;
  final String? customRecommendation;

  const TechnicalGauge({
    super.key,
    required this.value,
    this.result,
    this.onMoreTap,
    this.display = true,
    this.isAi = false,
    this.customRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize value to 0-1 range for gauge
    final normalizedValue = ((value + 100) / 200).clamp(0.0, 1.0);

    String recommendationLabel;
    if (customRecommendation != null) {
      recommendationLabel = customRecommendation!;
    } else if (result != null) {
      recommendationLabel = _getLocalizedRecommendation(
        context,
        result!.recommendation,
      );
    } else if (value < -60) {
      recommendationLabel = context.s.gauge_strong_sell;
    } else if (value < -20) {
      recommendationLabel = context.s.gauge_sell;
    } else if (value < 20) {
      recommendationLabel = context.s.gauge_neutral;
    } else if (value < 60) {
      recommendationLabel = context.s.gauge_buy;
    } else {
      recommendationLabel = context.s.gauge_strong_buy;
    }

    final rawRecommendation =
        customRecommendation ??
        result?.recommendation ??
        (value < -60
            ? 'Strong Sell'
            : value < -20
            ? 'Sell'
            : value < 20
            ? 'Neutral'
            : value < 60
            ? 'Buy'
            : 'Strong Buy');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gauge visualization
        SizedBox(
          height: 140,
          child: CustomPaint(
            size: const Size(double.infinity, 140),
            painter: _GaugePainter(
              value: normalizedValue,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              isDark: isDark,
              buyLabel: isAi ? 'Bullish' : context.s.gauge_buy,
              sellLabel: isAi ? 'Bearish' : context.s.gauge_sell,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Center recommendation text
        Center(
          child: Text(
            recommendationLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getRecommendationColor(rawRecommendation),
            ),
          ),
        ),

        // Indicator vote summary (Buy / Neutral / Sell counts)
        if (result != null && display) ...[
          const SizedBox(height: 12),
          _buildVoteSummary(context),

          const SizedBox(height: 16),

          // Individual indicator votes
          _buildIndicatorSection(
            context,
            context.s.gauge_trend_ma,
            result!.trendVotes,
            isDark,
          ),
          const SizedBox(height: 10),
          _buildIndicatorSection(
            context,
            context.s.gauge_oscillators,
            result!.oscillatorVotes,
            isDark,
          ),

          // Bollinger Bands bonus indicator
          if (result!.bollingerBuySignal) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.green[400], size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.s.gauge_bollinger_desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],

        const SizedBox(height: 16),

        // More technicals button
      ],
    );
  }

  /// Buy / Neutral / Sell vote count row
  Widget _buildVoteSummary(BuildContext context) {
    final buyCount = result!.buyCount;
    final neutralCount = result!.neutralCount;
    final sellCount = result!.sellCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _voteBadge(context.s.gauge_buy_count(buyCount), Colors.green[400]!),
        const SizedBox(width: 12),
        _voteBadge(
          context.s.gauge_neutral_count(neutralCount),
          Colors.grey[400]!,
        ),
        const SizedBox(width: 12),
        _voteBadge(context.s.gauge_sell_count(sellCount), Colors.red[400]!),
      ],
    );
  }

  Widget _voteBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Section showing individual indicator votes
  Widget _buildIndicatorSection(
    BuildContext context,
    String title,
    List<IndicatorVote> votes,
    bool isDark,
  ) {
    if (votes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        ...votes.map((vote) => _buildVoteRow(vote, isDark, context)),
      ],
    );
  }

  Widget _buildVoteRow(IndicatorVote vote, bool isDark, BuildContext context) {
    final color = _getSignalColor(vote.signal);
    final icon = _getSignalIcon(vote.signal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              vote.name,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
          if (vote.value != null)
            Text(
              _formatValue(vote.name, vote.value!),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontFamily: 'monospace',
              ),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _signalLabel(context, vote.signal),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(String name, double value) {
    if (name.contains('EMA')) {
      return value.toStringAsFixed(2);
    } else if (name.contains('RSI') || name.contains('Stochastic')) {
      return '${value.toStringAsFixed(1)}%';
    } else if (name.contains('MACD')) {
      return value.toStringAsFixed(4);
    }
    return value.toStringAsFixed(2);
  }

  Color _getSignalColor(IndicatorSignal signal) {
    switch (signal) {
      case IndicatorSignal.strongBuy:
      case IndicatorSignal.buy:
        return Colors.green[400]!;
      case IndicatorSignal.neutral:
        return Colors.grey[400]!;
      case IndicatorSignal.sell:
      case IndicatorSignal.strongSell:
        return Colors.red[400]!;
    }
  }

  IconData _getSignalIcon(IndicatorSignal signal) {
    switch (signal) {
      case IndicatorSignal.strongBuy:
      case IndicatorSignal.buy:
        return Icons.arrow_upward_rounded;
      case IndicatorSignal.neutral:
        return Icons.remove_rounded;
      case IndicatorSignal.sell:
      case IndicatorSignal.strongSell:
        return Icons.arrow_downward_rounded;
    }
  }

  String _signalLabel(BuildContext context, IndicatorSignal signal) {
    return _getLocalizedSignal(context, signal);
  }

  String _getLocalizedRecommendation(
    BuildContext context,
    String recommendation,
  ) {
    switch (recommendation) {
      case 'Strong Buy':
        return context.s.gauge_strong_buy;
      case 'Buy':
        return context.s.gauge_buy;
      case 'Sell':
        return context.s.gauge_sell;
      case 'Strong Sell':
        return context.s.gauge_strong_sell;
      case 'Neutral':
      default:
        return context.s.gauge_neutral;
    }
  }

  String _getLocalizedSignal(BuildContext context, IndicatorSignal signal) {
    switch (signal) {
      case IndicatorSignal.strongBuy:
        return context.s.gauge_strong_buy.toUpperCase();
      case IndicatorSignal.buy:
        return context.s.gauge_buy.toUpperCase();
      case IndicatorSignal.neutral:
        return context.s.gauge_neutral.toUpperCase();
      case IndicatorSignal.sell:
        return context.s.gauge_sell.toUpperCase();
      case IndicatorSignal.strongSell:
        return context.s.gauge_strong_sell.toUpperCase();
    }
  }

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation) {
      case 'Strong Buy':
        return Colors.green[600]!;
      case 'Buy':
        return Colors.green[400]!;
      case 'Sell':
        return Colors.red[400]!;
      case 'Strong Sell':
        return Colors.red[600]!;
      default:
        return Colors.grey[400]!;
    }
  }
}

class _GaugePainter extends CustomPainter {
  final double value; // 0 to 1
  final Color backgroundColor;
  final bool isDark;
  final String buyLabel;
  final String sellLabel;

  _GaugePainter({
    required this.value,
    required this.backgroundColor,
    required this.isDark,
    required this.buyLabel,
    required this.sellLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = math.min(size.width / 2, size.height - 20) - 20;

    // Draw background arc
    final bgPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start at left (180 degrees)
      math.pi, // Sweep 180 degrees to right
      false,
      bgPaint,
    );

    // Draw colored gradient arc in segments
    final segments = 50;
    final sweepAngle = math.pi / segments;

    for (int i = 0; i < segments; i++) {
      final progress = i / segments;
      final paint = Paint()
        ..color = _getColorForProgress(progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + (sweepAngle * i),
        sweepAngle,
        false,
        paint,
      );
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // "Sell" label
    textPainter.text = TextSpan(
      text: sellLabel,
      style: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(20, size.height - 30));

    // "Buy" label
    textPainter.text = TextSpan(
      text: buyLabel,
      style: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 40, size.height - 30));

    // Draw needle/pointer
    final needleAngle = math.pi + (math.pi * value);
    final needleLength = radius + 5;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center circle
    final centerCirclePaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerCirclePaint);
  }

  Color _getColorForProgress(double progress) {
    if (progress < 0.25) {
      // Strong sell - red
      return Color.lerp(Colors.red[700]!, Colors.red[500]!, progress * 4)!;
    } else if (progress < 0.5) {
      // Sell - orange/red
      return Color.lerp(
        Colors.red[500]!,
        Colors.orange[400]!,
        (progress - 0.25) * 4,
      )!;
    } else if (progress < 0.75) {
      // Buy - yellow/green
      return Color.lerp(
        Colors.orange[400]!,
        Colors.green[400]!,
        (progress - 0.5) * 4,
      )!;
    } else {
      // Strong buy - green
      return Color.lerp(
        Colors.green[400]!,
        Colors.green[600]!,
        (progress - 0.75) * 4,
      )!;
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
