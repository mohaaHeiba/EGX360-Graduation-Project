import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/markets/presentation/widgets/desktop/technical_gauge.dart';
import 'package:flutter/material.dart';

/// Collapsible AI prediction widget — shows gauge + toggleable full details inline.
class AiPredictionExpandable extends StatefulWidget {
  final AiPrediction prediction;

  const AiPredictionExpandable({super.key, required this.prediction});

  @override
  State<AiPredictionExpandable> createState() => _AiPredictionExpandableState();
}

class _AiPredictionExpandableState extends State<AiPredictionExpandable>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  AiPrediction get p => widget.prediction;

  @override
  Widget build(BuildContext context) {
    final cardBg = context.surface;
    final border = context.onSurface.withValues(alpha: 0.1);
    final labelColor = context.onSurface.withValues(alpha: 0.6);

    final mlSignal = p.rawFeatures['ml_signal']?.toString() ?? '-';
    final modelVersion = p.rawFeatures['model_version']?.toString() ?? '-';
    final overallTrend =
        p.rawFeatures['overall_trend']?.toString() ?? 'NEUTRAL';
    final isBullish = overallTrend.contains('BULL');
    final isBearish = overallTrend.contains('BEAR');
    final trendColor = isBullish
        ? AppColors.candleGreen
        : (isBearish ? AppColors.candleRed : AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Gauge — always visible ───────────────────────────────────────
        TechnicalGauge(
          value: p.score,
          isAi: true,
          customRecommendation: 'AI: ${p.recommendation}',
        ),

        const SizedBox(height: 14),

        // ── Toggle: Technical Breakdown ──────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _toggle,
            icon: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ),
            label: Text(
              _expanded
                  ? 'Hide Technical Breakdown'
                  : 'Show Technical Breakdown',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),

        // ── Collapsible: AI box + raw indicators ─────────────────────────
        SizeTransition(
          sizeFactor: _anim,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EGX360 ML Prediction
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.10),
                        AppColors.primary.withValues(alpha: 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.smart_toy_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EGX360 AI Prediction',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: trendColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: trendColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              overallTrend,
                              style: TextStyle(
                                fontSize: 10,
                                color: trendColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _sigCard(
                              'Signal',
                              mlSignal,
                              mlSignal == 'UP'
                                  ? AppColors.candleGreen
                                  : AppColors.candleRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _sigCard(
                              'Probability',
                              '${(p.probability * 100).toStringAsFixed(1)}%',
                              AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (modelVersion != '-') ...[
                            Text(
                              modelVersion,
                              style: TextStyle(
                                fontSize: 9,
                                color: labelColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: labelColor,
                                ),
                              ),
                            ),
                          ],
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: labelColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _timeAgo(p.createdAt),
                            style: TextStyle(fontSize: 9, color: labelColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Raw indicator details
                _AiDetailsBody(
                  prediction: p,
                  labelColor: labelColor,
                  cardBg: cardBg,
                  border: border,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _sigCard(String title, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ── Technical indicator details (raw data, used as collapsible content) ──────
class _AiDetailsBody extends StatelessWidget {
  final AiPrediction prediction;
  final Color labelColor, cardBg, border;

  const _AiDetailsBody({
    required this.prediction,
    required this.labelColor,
    required this.cardBg,
    required this.border,
  });

  double _d(String k) => (prediction.rawFeatures[k] as num?)?.toDouble() ?? 0;
  String _s(String k, [String fb = '-']) =>
      prediction.rawFeatures[k]?.toString() ?? fb;
  String _fmtD(String k, {int dec = 2}) {
    final v = prediction.rawFeatures[k];
    if (v == null) return '-';
    final d = (v as num).toDouble();
    return d.abs() > 10000
        ? d.toStringAsFixed(1)
        : (d.abs() > 1 ? d.toStringAsFixed(dec) : d.toStringAsFixed(5));
  }

  // Neutral color for 'Normal'/'Flat'/'Moderate' tags
  Color get _neutralTag => const Color(0xFF78909C); // blueGrey[400]

  @override
  Widget build(BuildContext context) {
    final rsi = _d('rsi');
    final rsiLag1 = _d('rsi_lag1');
    final rsiDiff = _d('rsi_diff');
    final macdHist = _d('macd_hist');
    final compositeMom = _d('composite_momentum');
    final atrPct = _d('atr_pct');
    final bbWidth = _d('bb_width');
    final ema9 = _d('ema_9');
    final ema10 = _d('ema_10');
    final ema20 = _d('ema_20');
    final ema50 = _d('ema_50');
    final emaCross = _d('ema_cross_signal');
    final belowEma9 = _d('below_ema9');
    final rvol = _d('rvol_50');
    final noise = _d('noise');
    final close = prediction.closePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart analysis
        _label('🧠 Smart Analysis'),
        const SizedBox(height: 8),
        _card(
          context: context,
          child: Column(
            children: [
              _sRow(
                'Momentum',
                _s('momentum_status'),
                _statusColor(_s('momentum_status')),
              ),
              _div(),
              _sRow('MACD', _s('macd_status'), _statusColor(_s('macd_status'))),
              _div(),
              _sRow(
                'Volatility',
                _s('volatility_status'),
                _statusColor(_s('volatility_status')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Market data grid
        const SizedBox(height: 16),

        // Momentum & oscillators
        _label('📉 Momentum & Oscillators'),
        const SizedBox(height: 8),
        _card(
          context: context,
          child: Column(
            children: [
              _iRow('RSI (14)', rsi.toStringAsFixed(2), _rsiSig(rsi)),
              _div(),
              _iRow('RSI Lag-1', rsiLag1.toStringAsFixed(2), _rsiSig(rsiLag1)),
              _div(),
              _iRow(
                'RSI Δ',
                rsiDiff.toStringAsFixed(4),
                rsiDiff > 0
                    ? _Sig('Accelerating', AppColors.candleGreen)
                    : (rsiDiff < 0
                          ? _Sig('Decelerating', AppColors.candleRed)
                          : _Sig('Flat', _neutralTag)),
              ),
              _div(),
              _iRow(
                'MACD Histogram',
                macdHist.toStringAsFixed(3),
                _macdSig(macdHist),
              ),
              _div(),
              _iRow(
                'Composite Momentum',
                compositeMom.toStringAsFixed(2),
                compositeMom > 70
                    ? _Sig('Overbought 🚨', AppColors.candleRed)
                    : (compositeMom < 30
                          ? _Sig('Oversold', AppColors.candleGreen)
                          : _Sig('Normal', _neutralTag)),
              ),
              _div(),
              _iRow(
                'ATR % (Volatility)',
                '${(atrPct * 100).toStringAsFixed(2)}%',
                atrPct > 0.02
                    ? _Sig('High Risk ⚠️', AppColors.candleRed)
                    : (atrPct < 0.008
                          ? _Sig('Low Risk', AppColors.candleGreen)
                          : _Sig('Moderate', _neutralTag)),
              ),
              _div(),
              _iRow(
                'BB Width',
                bbWidth.toStringAsFixed(4),
                bbWidth > 0.25
                    ? _Sig('Wide/Volatile', AppColors.candleRed)
                    : (bbWidth < 0.08
                          ? _Sig('Squeeze 🚀', AppColors.primary)
                          : _Sig('Normal', _neutralTag)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // EMA levels
        _label('📐 EMA Levels'),
        const SizedBox(height: 8),
        _card(
          context: context,
          child: Column(
            children: [
              _emaRow('EMA 9', ema9, close),
              _div(),
              _emaRow('EMA 10', ema10, close),
              _div(),
              _emaRow('EMA 20', ema20, close),
              _div(),
              _emaRow('EMA 50', ema50, close),
              _div(),
              _iRow(
                'EMA Cross (10>20)',
                emaCross == 1 ? 'Yes' : 'No',
                emaCross == 1
                    ? _Sig('Bullish ✅', AppColors.candleGreen)
                    : _Sig('Bearish ❌', AppColors.candleRed),
              ),
              _div(),
              _iRow(
                'Price Below EMA 9',
                belowEma9 == 1 ? 'Yes' : 'No',
                belowEma9 == 1
                    ? _Sig('Bearish ❌', AppColors.candleRed)
                    : _Sig('Bullish ✅', AppColors.candleGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Volume & Macro
        _label('🌍 Volume & Macro'),
        const SizedBox(height: 8),
        _card(
          context: context,
          child: Column(
            children: [
              _iRow(
                'RVOL 50 (Rel. Volume)',
                rvol.toStringAsFixed(3),
                rvol > 1.5
                    ? _Sig('High Volume 🔥', AppColors.candleGreen)
                    : (rvol < 0.7
                          ? _Sig('Low Volume', AppColors.candleRed)
                          : _Sig('Normal', _neutralTag)),
              ),
              _div(),
              _iRow(
                'Noise (Price - EMA10)',
                noise.toStringAsFixed(2),
                noise > 0
                    ? _Sig('Above EMA10', AppColors.candleGreen)
                    : (noise < 0
                          ? _Sig('Below EMA10', AppColors.candleRed)
                          : _Sig('At EMA10', _neutralTag)),
              ),
              _div(),
              _iRow(
                'Gold USD',
                _fmtD('gold_usd'),
                _goldSig(_d('gold_log_ret')),
              ),
              _div(),
              _iRow(
                'USD Shock',
                _d('usd_shock') == 1 ? 'Yes ⚡' : 'No',
                _d('usd_shock') == 1
                    ? _Sig('USD Spike ⚠️', AppColors.warning)
                    : _Sig('Stable', AppColors.candleGreen),
              ),
              _div(),
              _iRow(
                'Log Return',
                _fmtD('log_ret', dec: 6),
                _d('log_ret') > 0
                    ? _Sig('Positive', AppColors.candleGreen)
                    : (_d('log_ret') < 0
                          ? _Sig('Negative', AppColors.candleRed)
                          : _Sig('Flat', _neutralTag)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _card({required Widget child, required BuildContext context}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.surface.withOpacity(0.6),
              context.surface.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.onSurface.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: context.surface.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      );

  Widget _label(String t) => Text(
    t,
    style: TextStyle(
      fontSize: 12,
      color: labelColor,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _sRow(String label, String status, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            status == '-' ? 'N/A' : status,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _iRow(String label, String value, _Sig sig) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: sig.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: sig.color.withValues(alpha: 0.35)),
          ),
          child: Text(
            sig.label,
            style: TextStyle(
              fontSize: 10,
              color: sig.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _emaRow(String label, double emaVal, double close) {
    if (emaVal <= 0) return _iRow(label, '-', _Sig('N/A', AppColors.warning));
    final isAbove = close > emaVal;
    final pct = (close - emaVal) / emaVal * 100;
    return _iRow(
      '$label (${emaVal.toStringAsFixed(2)})',
      '${isAbove ? '+' : ''}${pct.toStringAsFixed(2)}% vs close',
      isAbove
          ? _Sig('Price Above ✅', AppColors.candleGreen)
          : _Sig('Price Below ❌', AppColors.candleRed),
    );
  }

  Widget _div() => Divider(color: border, height: 1);

  Widget _grid4(List<(String, String)> items) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      childAspectRatio: 1.4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemBuilder: (_, i) => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            items[i].$1,
            style: TextStyle(fontSize: 9, color: labelColor),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            items[i].$2,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  _Sig _rsiSig(double v) {
    if (v > 70) return _Sig('Overbought 🚨', AppColors.candleRed);
    if (v > 60) return _Sig('Bullish', AppColors.candleGreen);
    if (v < 30) return _Sig('Oversold 🟢', AppColors.candleGreen);
    if (v < 40) return _Sig('Bearish', AppColors.candleRed);
    return _Sig('Neutral', _neutralTag);
  }

  _Sig _macdSig(double h) {
    if (h > 200) return _Sig('Strong Bull 🚀', AppColors.candleGreen);
    if (h > 0) return _Sig('Bullish', AppColors.candleGreen);
    if (h < -200) return _Sig('Strong Bear 📉', AppColors.candleRed);
    if (h < 0) return _Sig('Bearish', AppColors.candleRed);
    return _Sig('Neutral', _neutralTag);
  }

  _Sig _goldSig(double lr) {
    if (lr > 0.01) return _Sig('Rising ↑', AppColors.candleGreen);
    if (lr < -0.01) return _Sig('Falling ↓', AppColors.candleRed);
    return _Sig('Stable', _neutralTag);
  }

  Color _statusColor(String s) {
    final l = s.toLowerCase();
    if (l.contains('high') || l.contains('bull')) return AppColors.candleGreen;
    if (l.contains('low') || l.contains('bear')) return AppColors.candleRed;
    if (l.contains('normal')) return _neutralTag;
    return _neutralTag;
  }

  String _fmtVol(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _Sig {
  final String label;
  final Color color;
  const _Sig(this.label, this.color);
}
