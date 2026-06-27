import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:flutter/material.dart';

class AiPredictionDetailsSheet extends StatelessWidget {
  final AiPrediction prediction;

  const AiPredictionDetailsSheet({super.key, required this.prediction});

  static void show(BuildContext context, AiPrediction prediction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiPredictionDetailsSheet(prediction: prediction),
    );
  }

  // ── Data helpers (flat Supabase format) ────────────────────────────────────
  String _s(String key, [String fallback = '-']) =>
      prediction.rawFeatures[key]?.toString() ?? fallback;

  double _d(String key, [double fallback = 0.0]) =>
      (prediction.rawFeatures[key] as num?)?.toDouble() ?? fallback;

  String _fmtD(String key, {int dec = 2}) {
    final v = prediction.rawFeatures[key];
    if (v == null) return '-';
    final d = (v as num).toDouble();
    if (d.abs() > 10000) return d.toStringAsFixed(1);
    if (d.abs() > 1) return d.toStringAsFixed(dec);
    return d.toStringAsFixed(5);
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.background;
    final cardBg = context.surface;
    final border = context.onSurface.withValues(alpha: 0.1);
    final labelColor = context.onSurface.withValues(alpha: 0.6);

    final overallTrend = _s('overall_trend', 'NEUTRAL');
    final isBullish = overallTrend.contains('BULL');
    final isBearish = overallTrend.contains('BEAR');
    final trendColor = isBullish ? AppColors.candleGreen : (isBearish ? AppColors.candleRed : AppColors.warning);

    final upPct = _d('consensus_up_pct', 50);
    final downPct = _d('consensus_down_pct', 50);
    final mlSignal = _s('ml_signal');
    final modelVersion = _s('model_version');
    final predDate = _s('prediction_date');

    // Technical indicators from flat columns
    final rsi = _d('rsi');
    final macdHist = _d('macd_hist');
    final atrPct = _d('atr_pct');
    final bbWidth = _d('bb_width');
    final compositeMom = _d('composite_momentum');
    final rsiLag1 = _d('rsi_lag1');
    final rsiDiff = _d('rsi_diff');
    final ema9 = _d('ema_9');
    final ema10 = _d('ema_10');
    final ema20 = _d('ema_20');
    final ema50 = _d('ema_50');
    final rvol = _d('rvol_50');
    final noise = _d('noise');
    final emaCrossSignal = _d('ema_cross_signal');
    final belowEma9 = _d('below_ema9');

    // Market data from flat columns
    final openPrice = _d('open_price', _d('open'));
    final highPrice = _d('high_price', _d('high'));
    final lowPrice = _d('low_price', _d('low'));
    final volume = _d('volume');
    final usdEgp = _d('usd_egp_rate');
    final goldEgp = _d('gold_egp');
    final closeUsd = _d('close_usd');

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  prediction.symbol,
                                  style: context.textStyles.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text('AI Analysis', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            if (predDate != '-') ...[
                              const SizedBox(height: 3),
                              Text('Prediction: $predDate', style: TextStyle(fontSize: 12, color: labelColor)),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: trendColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: trendColor.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isBullish ? Icons.trending_up_rounded : (isBearish ? Icons.trending_down_rounded : Icons.compare_arrows_rounded),
                                color: trendColor,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isBullish ? 'BULLISH' : (isBearish ? 'BEARISH' : 'NEUTRAL'),
                                style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Consensus Bar ─────────────────────────────────────
                    _sectionCard(
                      context,
                      cardBg,
                      border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Consensus Vote', style: TextStyle(fontSize: 13, color: labelColor, fontWeight: FontWeight.w600)),
                              Text(
                                'Up ${upPct.toStringAsFixed(1)}%  ·  Down ${downPct.toStringAsFixed(1)}%',
                                style: context.textStyles.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Row(
                              children: [
                                if (upPct > 0)
                                  Flexible(
                                    flex: upPct.round(),
                                    child: Container(height: 10, color: AppColors.candleGreen),
                                  ),
                                if (downPct > 0)
                                  Flexible(
                                    flex: downPct.round(),
                                    child: Container(height: 10, color: AppColors.candleRed),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _legendDot('Bullish', AppColors.candleGreen),
                              _legendDot('Bearish', AppColors.candleRed),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── ML Prediction ─────────────────────────────────────
                    _sectionTitle(context, '🤖  ML Prediction', labelColor),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _signalCard(context, 'Signal', mlSignal, mlSignal == 'UP' ? AppColors.candleGreen : AppColors.candleRed, cardBg, border)),
                        const SizedBox(width: 10),
                        Expanded(child: _signalCard(context, 'Confidence', '${(_d("consensus_up_pct")).toStringAsFixed(1)}%', trendColor, cardBg, border)),
                        const SizedBox(width: 10),
                        Expanded(child: _signalCard(context, 'Probability', '${(prediction.probability * 100).toStringAsFixed(1)}%', AppColors.primary, cardBg, border)),
                      ],
                    ),
                    if (modelVersion != '-') ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          'Model: $modelVersion',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: labelColor, fontFamily: 'monospace'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Smart Analysis ────────────────────────────────────
                    _sectionTitle(context, '🧠  Smart Analysis', labelColor),
                    const SizedBox(height: 10),
                    _sectionCard(
                      context, cardBg, border,
                      child: Column(
                        children: [
                          _smartRow(context, 'Momentum', _s('momentum_status'), _getStatusColor(_s('momentum_status')), labelColor),
                          const SizedBox(height: 10),
                          _smartRow(context, 'MACD', _s('macd_status'), _getStatusColor(_s('macd_status')), labelColor),
                          const SizedBox(height: 10),
                          _smartRow(context, 'Volatility', _s('volatility_status'), _getStatusColor(_s('volatility_status')), labelColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Market Data ───────────────────────────────────────
                    _sectionTitle(context, '📊  Market Data', labelColor),
                    const SizedBox(height: 10),
                    _dataGrid(context, [
                      ('Open', openPrice > 0 ? openPrice.toStringAsFixed(2) : '-'),
                      ('High', highPrice > 0 ? highPrice.toStringAsFixed(2) : '-'),
                      ('Low', lowPrice > 0 ? lowPrice.toStringAsFixed(2) : '-'),
                      ('Close', prediction.closePrice.toStringAsFixed(2)),
                      ('USD/EGP', usdEgp > 0 ? usdEgp.toStringAsFixed(3) : '-'),
                      ('Gold/EGP', goldEgp > 0 ? goldEgp.toStringAsFixed(0) : '-'),
                      ('Close USD', closeUsd > 0 ? closeUsd.toStringAsFixed(3) : '-'),
                      ('Volume', volume > 0 ? _fmtVolume(volume) : '-'),
                    ], cardBg, border, labelColor),

                    const SizedBox(height: 20),

                    // ── Momentum & Oscillators ────────────────────────────
                    _sectionTitle(context, '📉  Momentum & Oscillators', labelColor),
                    const SizedBox(height: 10),
                    _sectionCard(
                      context, cardBg, border,
                      child: Column(
                        children: [
                          _interpretedRow(context, 'RSI (14)', rsi.toStringAsFixed(2), _rsiSignal(rsi), labelColor),
                          _divider(border),
                          _interpretedRow(context, 'RSI Lag-1', rsiLag1.toStringAsFixed(2), _rsiSignal(rsiLag1), labelColor),
                          _divider(border),
                          _interpretedRow(context, 'RSI Δ (momentum shift)', rsiDiff.toStringAsFixed(4),
                            rsiDiff > 0 ? _Sig('Accelerating', AppColors.candleGreen) : (rsiDiff < 0 ? _Sig('Decelerating', AppColors.candleRed) : _Sig('Flat', AppColors.warning)),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'MACD Histogram', macdHist.toStringAsFixed(3), _macdSignal(macdHist), labelColor),
                          _divider(border),
                          _interpretedRow(context, 'Composite Momentum', compositeMom.toStringAsFixed(2),
                            compositeMom > 70 ? _Sig('Overbought 🚨', AppColors.candleRed) : (compositeMom < 30 ? _Sig('Oversold 🟢', AppColors.candleGreen) : _Sig('Normal', AppColors.warning)),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'ATR % (Volatility)', '${(atrPct * 100).toStringAsFixed(2)}%',
                            atrPct > 0.02 ? _Sig('High Risk ⚠️', AppColors.candleRed) : (atrPct < 0.008 ? _Sig('Low Risk', AppColors.candleGreen) : _Sig('Moderate', AppColors.warning)),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'BB Width (Squeeze)', bbWidth.toStringAsFixed(4),
                            bbWidth > 0.25 ? _Sig('Wide / Volatile', AppColors.candleRed) : (bbWidth < 0.08 ? _Sig('Squeeze 🚀', AppColors.primary) : _Sig('Normal', AppColors.warning)),
                            labelColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── EMA Levels ────────────────────────────────────────
                    _sectionTitle(context, '📐  EMA Levels', labelColor),
                    const SizedBox(height: 10),
                    _sectionCard(
                      context, cardBg, border,
                      child: Column(
                        children: [
                          _emaRow(context, 'EMA 9', ema9, prediction.closePrice, labelColor, border),
                          _divider(border),
                          _emaRow(context, 'EMA 10', ema10, prediction.closePrice, labelColor, border),
                          _divider(border),
                          _emaRow(context, 'EMA 20', ema20, prediction.closePrice, labelColor, border),
                          _divider(border),
                          _emaRow(context, 'EMA 50', ema50, prediction.closePrice, labelColor, border),
                          _divider(border),
                          _interpretedRow(context, 'EMA Cross (10 > 20)', emaCrossSignal == 1 ? 'Yes' : 'No',
                            emaCrossSignal == 1 ? _Sig('Bullish ✅', AppColors.candleGreen) : _Sig('Bearish ❌', AppColors.candleRed),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'Price below EMA 9', belowEma9 == 1 ? 'Yes' : 'No',
                            belowEma9 == 1 ? _Sig('Bearish ❌', AppColors.candleRed) : _Sig('Bullish ✅', AppColors.candleGreen),
                            labelColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Volume & Macro ────────────────────────────────────
                    _sectionTitle(context, '🌍  Volume & Macro', labelColor),
                    const SizedBox(height: 10),
                    _sectionCard(
                      context, cardBg, border,
                      child: Column(
                        children: [
                          _interpretedRow(context, 'RVOL 50 (Rel. Volume)', rvol.toStringAsFixed(3),
                            rvol > 1.5 ? _Sig('High Volume 🔥', AppColors.candleGreen) : (rvol < 0.7 ? _Sig('Low Volume', AppColors.candleRed) : _Sig('Normal', AppColors.warning)),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'Noise (Price - EMA10)', noise.toStringAsFixed(2),
                            noise > 0 ? _Sig('Above EMA10', AppColors.candleGreen) : (noise < 0 ? _Sig('Below EMA10', AppColors.candleRed) : _Sig('At EMA10', AppColors.warning)),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'Gold USD', _fmtD('gold_usd', dec: 2), _goldSignal(_d('gold_log_ret')), labelColor),
                          _divider(border),
                          _interpretedRow(context, 'USD Shock', _d('usd_shock') == 1 ? 'Yes ⚡' : 'No',
                            _d('usd_shock') == 1 ? _Sig('USD Spike ⚠️', AppColors.warning) : _Sig('Stable', AppColors.candleGreen),
                            labelColor),
                          _divider(border),
                          _interpretedRow(context, 'Log Return', _fmtD('log_ret', dec: 6),
                            _d('log_ret') > 0 ? _Sig('Positive', AppColors.candleGreen) : (_d('log_ret') < 0 ? _Sig('Negative', AppColors.candleRed) : _Sig('Flat', AppColors.warning)),
                            labelColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Reusable widgets ───────────────────────────────────────────────────────

  Widget _sectionCard(BuildContext context, Color bg, Color border, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title, Color labelColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 13, color: labelColor, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    );
  }

  Widget _signalCard(BuildContext context, String title, String value, Color color, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _smartRow(BuildContext context, String label, String status, Color color, Color labelColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(status == '-' ? 'N/A' : status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _interpretedRow(BuildContext context, String label, String value, _Sig signal, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: signal.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: signal.color.withValues(alpha: 0.35)),
            ),
            child: Text(signal.label, style: TextStyle(fontSize: 11, color: signal.color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _emaRow(BuildContext context, String label, double emaVal, double closePrice, Color labelColor, Color border) {
    final isAbove = closePrice > emaVal;
    final diff = closePrice - emaVal;
    final pct = emaVal > 0 ? (diff / emaVal * 100) : 0.0;
    final sig = isAbove
        ? _Sig('Price Above ✅', AppColors.candleGreen)
        : _Sig('Price Below ❌', AppColors.candleRed);
    return _interpretedRow(
      context,
      '$label  (${emaVal.toStringAsFixed(2)})',
      '${isAbove ? '+' : ''}${pct.toStringAsFixed(2)}% vs close',
      sig,
      labelColor,
    );
  }

  Widget _divider(Color border) => Divider(color: border, height: 1);

  Widget _indicatorRow(BuildContext context, String label, double value, Color labelColor, {double? min, double? max, double? dangerLow, double? dangerHigh}) {
    Color valColor = context.onSurface;
    if (dangerLow != null && value < dangerLow) valColor = AppColors.candleGreen;
    else if (dangerHigh != null && value > dangerHigh) valColor = AppColors.candleRed;
    else if (value > 0) valColor = AppColors.candleGreen;
    else if (value < 0) valColor = AppColors.candleRed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        Text(
          value.abs() > 1000 ? value.toStringAsFixed(1) : value.toStringAsFixed(4),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valColor, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _dataGrid(BuildContext context, List<(String, String)> items, Color cardBg, Color border, Color labelColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.$1, style: TextStyle(fontSize: 9, color: labelColor), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(item.$2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('high') || s.contains('bull') || s.contains('normal')) return AppColors.candleGreen;
    if (s.contains('low') || s.contains('bear')) return AppColors.candleRed;
    if (s.contains('neutral') || s.contains('sideways')) return AppColors.warning;
    return AppColors.primary;
  }

  _Sig _rsiSignal(double rsi) {
    if (rsi > 70) return _Sig('Overbought 🚨', AppColors.candleRed);
    if (rsi > 60) return _Sig('Bullish', AppColors.candleGreen);
    if (rsi < 30) return _Sig('Oversold 🟢', AppColors.candleGreen);
    if (rsi < 40) return _Sig('Bearish', AppColors.candleRed);
    return _Sig('Neutral', AppColors.warning);
  }

  _Sig _macdSignal(double hist) {
    if (hist > 200) return _Sig('Strong Bull 🚀', AppColors.candleGreen);
    if (hist > 0) return _Sig('Bullish', AppColors.candleGreen);
    if (hist < -200) return _Sig('Strong Bear 📉', AppColors.candleRed);
    if (hist < 0) return _Sig('Bearish', AppColors.candleRed);
    return _Sig('Neutral', AppColors.warning);
  }

  _Sig _goldSignal(double logRet) {
    if (logRet > 0.01) return _Sig('Rising ↑', AppColors.candleGreen);
    if (logRet < -0.01) return _Sig('Falling ↓', AppColors.candleRed);
    return _Sig('Stable', AppColors.warning);
  }

  String _fmtVolume(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

/// Simple signal label + color pair for indicator interpretation.
class _Sig {
  final String label;
  final Color color;
  const _Sig(this.label, this.color);
}
