import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExperienceStep extends GetView<OnboardingController> {
  const ExperienceStep({super.key});

  static const _options = [
    _Option('Beginner', '🌱', 'Just starting out, need guidance'),
    _Option('Intermediate', '📊', 'Some market experience'),
    _Option('Expert', '🏆', 'Professional trader & analyst'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Text(
            'What\'s your\ninvesting experience?',
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
            'We\'ll personalize your portfolio based on your level.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.onBackground.withOpacity(0.55),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 36),

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

  Widget _buildCard(BuildContext context, _Option opt) {
    return Obx(() {
      final isSelected = controller.experience.value == opt.value;
      return GestureDetector(
        onTap: () => controller.experience.value = opt.value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : context.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.surface,
              width: isSelected ? 1.8 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Emoji bubble
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : context.onSurface.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(opt.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt.value,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isSelected
                            ? AppColors.primary
                            : context.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opt.subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.onSurface.withOpacity(0.5),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : context.onSurface.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 15)
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Option {
  final String value;
  final String emoji;
  final String subtitle;
  const _Option(this.value, this.emoji, this.subtitle);
}
