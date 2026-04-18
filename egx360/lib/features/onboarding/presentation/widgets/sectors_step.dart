import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectorsStep extends GetView<OnboardingController> {
  const SectorsStep({super.key});

  static const _sectors = [
    _Sector('Banks', 'Banks', '🏦'),
    _Sector('Real Estate', 'Real Estate', '🏗️'),
    _Sector('Services', 'Services', '⚙️'),
    _Sector('Industrial', 'Industrial', '🏭'),
    _Sector('Food & Beverage', 'Food & Bev.', '🍔'),
    _Sector('Healthcare', 'Healthcare', '🏥'),
    _Sector('Building Materials', 'Build. Mat.', '🧱'),
    _Sector('Technology', 'Technology', '💻'),
    _Sector('Telecom', 'Telecom', '📡'),
    _Sector('Tourism', 'Tourism', '✈️'),
    _Sector('Education', 'Education', '📚'),
    _Sector('Energy', 'Energy', '⚡'),
    _Sector('Chemicals', 'Chemicals', '🧪'),
    _Sector('Crypto', 'Crypto', '₿'),
    _Sector('Currencies', 'Currencies', '💱'),
    _Sector('Materials', 'Metals', '🥇'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step badge
              Text(
                'Which sectors\ninterest you?',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.onBackground,
                  fontSize: 26,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  '${controller.selectedSectors.length} selected — pick as many as you like.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.onBackground.withOpacity(0.55),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable grid fills the rest ────────────────────────
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: _sectors.length,
                    (context, i) {
                      final s = _sectors[i];
                      // Each item owns its Obx — safe inside a sliver delegate
                      return Obx(() {
                        final isSelected = controller.selectedSectors.contains(
                          s.key,
                        );
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              controller.selectedSectors.remove(s.key);
                            } else {
                              controller.selectedSectors.add(s.key);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.12)
                                  : context.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.surface,
                                width: isSelected ? 1.5 : 0.8,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.18,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    s.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : context.onSurface.withOpacity(0.75),
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sector {
  final String key;
  final String label;
  final String emoji;
  const _Sector(this.key, this.label, this.emoji);
}
