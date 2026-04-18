import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalStep extends GetView<OnboardingController> {
  const GoalStep({super.key});

  static final _options = [
    _GoalOption(
      'Safe',
      '🛡️',
      'Preserve capital, low risk',
      0.2,
      const Color(0xFF00D97E),
    ),
    _GoalOption(
      'Balanced',
      '⚖️',
      'Moderate growth, calculated risk',
      0.55,
      const Color(0xFFF6C000),
    ),
    _GoalOption(
      'Aggressive',
      '🚀',
      'High returns, high risk tolerance',
      0.9,
      const Color(0xFFFF5252),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your\ninvestment goal?',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.onBackground,
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'This determines how we balance your virtual portfolio.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.onBackground.withOpacity(0.55),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          ..._options.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildCard(context, opt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _GoalOption opt) {
    return Obx(() {
      final isSelected = controller.goal.value == opt.value;
      return GestureDetector(
        onTap: () => controller.goal.value = opt.value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.10)
                : context.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.surface,
              width: isSelected ? 1.8 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        opt.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.value,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.primary
                                : context.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          opt.subtitle,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.onSurface.withOpacity(0.5),
                            height: 1.3,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : context.onSurface.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.black, size: 14)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Compact risk bar
              Row(
                children: [
                  Text(
                    'Risk',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.onSurface.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.onSurface.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          widthFactor: opt.riskLevel,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? opt.riskColor
                                  : opt.riskColor.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: opt.riskColor.withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(opt.riskLevel * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? opt.riskColor
                          : context.onSurface.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _GoalOption {
  final String value;
  final String emoji;
  final String subtitle;
  final double riskLevel;
  final Color riskColor;
  const _GoalOption(
    this.value,
    this.emoji,
    this.subtitle,
    this.riskLevel,
    this.riskColor,
  );
}
