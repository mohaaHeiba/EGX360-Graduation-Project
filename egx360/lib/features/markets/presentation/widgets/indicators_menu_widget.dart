import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration class for indicator settings
class IndicatorConfig {
  final bool enabled;
  final int period;
  final int? standardDeviation; // For Bollinger Bands

  const IndicatorConfig({
    this.enabled = false,
    this.period = 14,
    this.standardDeviation,
  });

  IndicatorConfig copyWith({
    bool? enabled,
    int? period,
    int? standardDeviation,
  }) {
    return IndicatorConfig(
      enabled: enabled ?? this.enabled,
      period: period ?? this.period,
      standardDeviation: standardDeviation ?? this.standardDeviation,
    );
  }
}

/// Widget to display indicators menu bottom sheet
class IndicatorsMenuWidget extends StatelessWidget {
  final IndicatorConfig smaConfig;
  final IndicatorConfig emaConfig;
  final IndicatorConfig bollingerConfig;
  final IndicatorConfig rsiConfig;
  final bool showVolume;
  final ValueChanged<IndicatorConfig> onSMAChanged;
  final ValueChanged<IndicatorConfig> onEMAChanged;
  final ValueChanged<IndicatorConfig> onBollingerChanged;
  final ValueChanged<IndicatorConfig> onRSIChanged;
  final ValueChanged<bool> onVolumeChanged;

  const IndicatorsMenuWidget({
    super.key,
    required this.smaConfig,
    required this.emaConfig,
    required this.bollingerConfig,
    required this.rsiConfig,
    required this.showVolume,
    required this.onSMAChanged,
    required this.onEMAChanged,
    required this.onBollingerChanged,
    required this.onRSIChanged,
    required this.onVolumeChanged,
  });

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
              Icon(Icons.analytics_outlined, color: context.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                context.s.indicators_title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.s.indicators_config_hint,
            style: TextStyle(
              fontSize: 13,
              color: context.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),

          // Indicators Grid - 2 per row
          Column(
            children: [
              // First row: SMA and EMA
              Row(
                children: [
                  Expanded(
                    child: _IndicatorChip(
                      label: context.s.indicators_sma_short,
                      sublabel: context.s.indicators_period_val(
                        smaConfig.period,
                      ),
                      color: Colors.orange,
                      isEnabled: smaConfig.enabled,
                      onTap: () => _showIndicatorSettings(
                        context,
                        title: context.s.indicators_sma,
                        description: context.s.indicators_sma_desc,
                        config: smaConfig,
                        color: Colors.orange,
                        defaultPeriod: 14,
                        onChanged: onSMAChanged,
                      ),
                      onToggle: (enabled) =>
                          onSMAChanged(smaConfig.copyWith(enabled: enabled)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _IndicatorChip(
                      label: context.s.indicators_ema_short,
                      sublabel: context.s.indicators_period_val(
                        emaConfig.period,
                      ),
                      color: Colors.blue,
                      isEnabled: emaConfig.enabled,
                      onTap: () => _showIndicatorSettings(
                        context,
                        title: context.s.indicators_ema,
                        description: context.s.indicators_ema_desc,
                        config: emaConfig,
                        color: Colors.blue,
                        defaultPeriod: 14,
                        onChanged: onEMAChanged,
                      ),
                      onToggle: (enabled) =>
                          onEMAChanged(emaConfig.copyWith(enabled: enabled)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Second row: Bollinger and RSI
              Row(
                children: [
                  Expanded(
                    child: _IndicatorChip(
                      label: context.s.indicators_bollinger_short,
                      sublabel: context.s.indicators_bollinger_val(
                        bollingerConfig.period,
                        bollingerConfig.standardDeviation ?? 2,
                      ),
                      color: Colors.teal,
                      isEnabled: bollingerConfig.enabled,
                      onTap: () => _showBollingerSettings(
                        context,
                        config: bollingerConfig,
                        onChanged: onBollingerChanged,
                      ),
                      onToggle: (enabled) => onBollingerChanged(
                        bollingerConfig.copyWith(enabled: enabled),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _IndicatorChip(
                      label: context.s.indicators_rsi_short,
                      sublabel: context.s.indicators_period_val(
                        rsiConfig.period,
                      ),
                      color: Colors.purple,
                      isEnabled: rsiConfig.enabled,
                      onTap: () => _showIndicatorSettings(
                        context,
                        title: context.s.indicators_rsi,
                        description: context.s.indicators_rsi_desc,
                        config: rsiConfig,
                        color: Colors.purple,
                        defaultPeriod: 14,
                        onChanged: onRSIChanged,
                      ),
                      onToggle: (enabled) =>
                          onRSIChanged(rsiConfig.copyWith(enabled: enabled)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Volume Toggle
          _VolumeToggle(isEnabled: showVolume, onChanged: onVolumeChanged),
        ],
      ),
    );
  }

  void _showIndicatorSettings(
    BuildContext context, {
    required String title,
    required String description,
    required IndicatorConfig config,
    required Color color,
    required int defaultPeriod,
    required ValueChanged<IndicatorConfig> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _IndicatorSettingsSheet(
        title: title,
        description: description,
        config: config,
        color: color,
        defaultPeriod: defaultPeriod,
        onChanged: onChanged,
      ),
    );
  }

  void _showBollingerSettings(
    BuildContext context, {
    required IndicatorConfig config,
    required ValueChanged<IndicatorConfig> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _BollingerSettingsSheet(config: config, onChanged: onChanged),
    );
  }
}

/// Indicator chip widget for the main menu
class _IndicatorChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const _IndicatorChip({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isEnabled,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.15) : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? color : context.onSurface.withOpacity(0.2),
            width: isEnabled ? 2 : 1,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            // Label and sublabel
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? color : context.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: context.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Toggle switch
            GestureDetector(
              onTap: () => onToggle(!isEnabled),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isEnabled ? color : context.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: isEnabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Volume toggle widget
class _VolumeToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const _VolumeToggle({required this.isEnabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? context.primary.withOpacity(0.1) : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? context.primary
                : context.onSurface.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: isEnabled ? context.primary : context.onSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.s.indicators_volume,
                    style: TextStyle(
                      color: isEnabled ? context.primary : context.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    context.s.indicators_volume_desc,
                    style: TextStyle(
                      color: context.onSurface.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onChanged,
              activeColor: context.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings sheet for simple indicators (SMA, EMA, RSI)
class _IndicatorSettingsSheet extends StatefulWidget {
  final String title;
  final String description;
  final IndicatorConfig config;
  final Color color;
  final int defaultPeriod;
  final ValueChanged<IndicatorConfig> onChanged;

  const _IndicatorSettingsSheet({
    required this.title,
    required this.description,
    required this.config,
    required this.color,
    required this.defaultPeriod,
    required this.onChanged,
  });

  @override
  State<_IndicatorSettingsSheet> createState() =>
      _IndicatorSettingsSheetState();
}

class _IndicatorSettingsSheetState extends State<_IndicatorSettingsSheet> {
  late bool _isEnabled;
  late TextEditingController _periodController;
  final FocusNode _periodFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.config.enabled;
    _periodController = TextEditingController(
      text: widget.config.period.toString(),
    );
  }

  @override
  void dispose() {
    _periodController.dispose();
    _periodFocusNode.dispose();
    super.dispose();
  }

  int get _currentPeriod {
    final value = int.tryParse(_periodController.text);
    if (value != null && value >= 1 && value <= 500) {
      return value;
    }
    return widget.defaultPeriod;
  }

  void _applyChanges() {
    widget.onChanged(
      IndicatorConfig(enabled: _isEnabled, period: _currentPeriod),
    );
    Navigator.pop(context);
  }

  void _resetToDefault() {
    setState(() {
      _periodController.text = widget.defaultPeriod.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.show_chart, color: widget.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: context.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Enable/Disable Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isEnabled
                    ? widget.color.withOpacity(0.1)
                    : context.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isEnabled
                      ? widget.color
                      : context.onSurface.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    context.s.indicators_enable,
                    style: TextStyle(
                      color: context.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() => _isEnabled = value);
                    },
                    activeColor: widget.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Period Input
            Text(
              context.s.indicators_period,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.s.indicators_period_desc(widget.defaultPeriod),
              style: TextStyle(
                fontSize: 12,
                color: context.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),

            // Period Text Field
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.onSurface.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _periodController,
                      focusNode: _periodFocusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        hintText: widget.defaultPeriod.toString(),
                        hintStyle: TextStyle(
                          color: context.onSurface.withOpacity(0.3),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reset to default button
                TextButton.icon(
                  onPressed: _resetToDefault,
                  icon: Icon(
                    Icons.refresh,
                    size: 18,
                    color: context.onSurface.withOpacity(0.6),
                  ),
                  label: Text(
                    context.s.indicators_default,
                    style: TextStyle(color: context.onSurface.withOpacity(0.6)),
                  ),
                ),
              ],
            ),

            // Quick period suggestions
            const SizedBox(height: 12),
            Text(
              context.s.indicators_quick_select,
              style: TextStyle(
                fontSize: 12,
                color: context.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [7, 14, 20, 50, 100, 200].map((period) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _periodController.text = period.toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.onSurface.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      period.toString(),
                      style: TextStyle(
                        color: context.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.s.indicators_apply,
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
      ),
    );
  }
}

/// Settings sheet for Bollinger Bands
class _BollingerSettingsSheet extends StatefulWidget {
  final IndicatorConfig config;
  final ValueChanged<IndicatorConfig> onChanged;

  const _BollingerSettingsSheet({
    required this.config,
    required this.onChanged,
  });

  @override
  State<_BollingerSettingsSheet> createState() =>
      _BollingerSettingsSheetState();
}

class _BollingerSettingsSheetState extends State<_BollingerSettingsSheet> {
  late bool _isEnabled;
  late TextEditingController _periodController;
  late int _selectedStdDev;

  static const int defaultPeriod = 20;
  static const int defaultStdDev = 2;
  static const List<int> stdDevOptions = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.config.enabled;
    _periodController = TextEditingController(
      text: widget.config.period.toString(),
    );
    _selectedStdDev = widget.config.standardDeviation ?? defaultStdDev;
  }

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  int get _currentPeriod {
    final value = int.tryParse(_periodController.text);
    if (value != null && value >= 1 && value <= 500) {
      return value;
    }
    return defaultPeriod;
  }

  void _applyChanges() {
    widget.onChanged(
      IndicatorConfig(
        enabled: _isEnabled,
        period: _currentPeriod,
        standardDeviation: _selectedStdDev,
      ),
    );
    Navigator.pop(context);
  }

  void _resetToDefault() {
    setState(() {
      _periodController.text = defaultPeriod.toString();
      _selectedStdDev = defaultStdDev;
    });
  }

  @override
  Widget build(BuildContext context) {
    const color = Colors.teal;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.stacked_line_chart,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    context.s.indicators_bollinger,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: context.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              context.s.indicators_bollinger_desc,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Enable/Disable Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isEnabled ? color.withOpacity(0.1) : context.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isEnabled
                      ? color
                      : context.onSurface.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    context.s.indicators_enable,
                    style: TextStyle(
                      color: context.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() => _isEnabled = value);
                    },
                    activeColor: color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Period Input
            Row(
              children: [
                Text(
                  context.s.indicators_period,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _resetToDefault,
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: context.onSurface.withOpacity(0.6),
                  ),
                  label: Text(
                    context.s.indicators_reset,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.s.indicators_period_desc(defaultPeriod),
              style: TextStyle(
                fontSize: 12,
                color: context.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),

            // Period Text Field with Quick Select
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.onSurface.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _periodController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        hintText: defaultPeriod.toString(),
                        hintStyle: TextStyle(
                          color: context.onSurface.withOpacity(0.3),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Quick period buttons
                ...[10, 20, 50].map((period) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _periodController.text = period.toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.onSurface.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          period.toString(),
                          style: TextStyle(
                            color: context.onSurface.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Standard Deviation Selection
            Text(
              context.s.indicators_std_dev,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.s.indicators_std_dev_desc(defaultStdDev),
              style: TextStyle(
                fontSize: 12,
                color: context.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: stdDevOptions.map((stdDev) {
                final isSelected = _selectedStdDev == stdDev;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedStdDev = stdDev);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: stdDev != stdDevOptions.last ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color : context.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : context.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${stdDev}σ",
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : context.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stdDev == 1
                                ? context.s.indicators_tight
                                : stdDev == 2
                                ? context.s.indicators_normal
                                : context.s.indicators_wide,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : context.onSurface.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.s.indicators_apply,
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
      ),
    );
  }
}
