import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/features/simulation/domain/entities/protection_rule_entity.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProtectionRuleSheet extends StatefulWidget {
  final String symbol;
  final ProtectionRuleEntity? existingRule;

  const ProtectionRuleSheet({
    super.key,
    required this.symbol,
    this.existingRule,
  });

  static Future<void> show(BuildContext context, String symbol) async {
    SimulationController? controller;
    try {
      controller = Get.find<SimulationController>();
    } catch (_) {}

    final existingRule = controller?.getProtectionRule(symbol);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProtectionRuleSheet(symbol: symbol, existingRule: existingRule),
    );
  }

  @override
  State<ProtectionRuleSheet> createState() => _ProtectionRuleSheetState();
}

class _ProtectionRuleSheetState extends State<ProtectionRuleSheet> {
  late double _alertPercentage;
  late double _liquidationPercentage;
  late bool _isAlertEnabled;
  late bool _isSellEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _alertPercentage = widget.existingRule?.alertPercentage ?? 5.0;
    _liquidationPercentage = widget.existingRule?.liquidationPercentage ?? 10.0;
    _isAlertEnabled = widget.existingRule?.isAlertEnabled ?? false;
    _isSellEnabled = widget.existingRule?.isSellEnabled ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final hasExisting = widget.existingRule != null;

    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.s.sim_capital_protection,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                        ),
                      ),
                      Text(
                        widget.symbol,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Alert Toggle + Slider ──
            _buildFeatureToggle(
              icon: Icons.notifications_active,
              title: context.s.sim_alert_me,
              subtitle: context.s.sim_alert_desc,
              color: Colors.amber,
              isEnabled: _isAlertEnabled,
              onToggle: (val) => setState(() => _isAlertEnabled = val),
            ),
            if (_isAlertEnabled) ...[
              const SizedBox(height: 8),
              _buildSliderSection(
                value: _alertPercentage,
                min: 1.0,
                max: 25.0,
                color: Colors.amber,
                onChanged: (val) {
                  setState(() {
                    _alertPercentage = val;
                    if (_liquidationPercentage < _alertPercentage) {
                      _liquidationPercentage = _alertPercentage;
                    }
                  });
                },
              ),
            ],
            const SizedBox(height: 16),

            // ── Auto-Sell Toggle + Slider ──
            _buildFeatureToggle(
              icon: Icons.gavel,
              title: context.s.sim_auto_sell_protection,
              subtitle: context.s.sim_auto_sell_desc,
              color: AppColors.candleRed,
              isEnabled: _isSellEnabled,
              onToggle: (val) => setState(() => _isSellEnabled = val),
            ),
            if (_isSellEnabled) ...[
              const SizedBox(height: 8),
              _buildSliderSection(
                value: _liquidationPercentage,
                min: _alertPercentage,
                max: 50.0,
                color: AppColors.candleRed,
                onChanged: (val) {
                  setState(() => _liquidationPercentage = val);
                },
              ),
            ],
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: context.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildInfoText(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (hasExisting) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _deleteRule,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(context.s.sim_remove),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.candleRed,
                        side: BorderSide(
                          color: AppColors.candleRed.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: hasExisting ? 2 : 1,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveRule,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.shield, size: 18),
                    label: Text(
                      hasExisting
                          ? context.s.sim_update_rule
                          : context.s.sim_save_rule,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildInfoText() {
    if (!_isAlertEnabled && !_isSellEnabled) {
      return context.s.sim_both_disabled_msg;
    }
    final parts = <String>[];
    if (_isAlertEnabled) {
      parts.add(
        context.s.sim_alert_at_msg(_alertPercentage.toStringAsFixed(1)),
      );
    }
    if (_isSellEnabled) {
      parts.add(
        context.s.sim_auto_sell_at_msg(
          _liquidationPercentage.toStringAsFixed(1),
        ),
      );
    }
    return '${parts.join(', ')}.';
  }

  Widget _buildFeatureToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isEnabled
            ? color.withOpacity(0.05)
            : context.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? color.withOpacity(0.2)
              : context.onSurface.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isEnabled ? color : context.onSurface.withOpacity(0.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEnabled
                        ? context.onSurface
                        : context.onSurface.withOpacity(0.5),
                  ),
                ),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.onSurface.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: isEnabled, activeColor: color, onChanged: onToggle),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required double value,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: color.withOpacity(0.15),
                overlayColor: color.withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) * 2).round().clamp(1, 100),
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRule() async {
    setState(() => _isSaving = true);
    try {
      final controller = Get.find<SimulationController>();
      await controller.saveProtectionRule(
        symbol: widget.symbol,
        alertPercentage: _alertPercentage,
        liquidationPercentage: _liquidationPercentage,
        isAlertEnabled: _isAlertEnabled,
        isSellEnabled: _isSellEnabled,
      );
      if (mounted) {
        Navigator.pop(context);
        customSnackbar(
          title: context.s.success_label,
          message: context.s.sim_protection_saved(widget.symbol),
          color: AppColors.candleGreen,
        );
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          title: context.s.error_label,
          message: context.s.sim_failed_to_save_rule(e.toString()),
          color: AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteRule() async {
    setState(() => _isSaving = true);
    try {
      final controller = Get.find<SimulationController>();
      await controller.deleteProtectionRule(widget.symbol);
      if (mounted) {
        Navigator.pop(context);
        customSnackbar(
          title: context.s.success_label,
          message: context.s.sim_protection_removed(widget.symbol),
          color: Colors.orange,
        );
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          title: context.s.error_label,
          message: context.s.sim_failed_to_remove_rule(e.toString()),
          color: AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
