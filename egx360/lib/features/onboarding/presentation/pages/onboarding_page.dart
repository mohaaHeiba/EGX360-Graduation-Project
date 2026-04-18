import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/background/custom_background.dart';
import 'package:egx/core/custom/custom_loading.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:egx/features/onboarding/presentation/widgets/experience_step.dart';
import 'package:egx/features/onboarding/presentation/widgets/goal_step.dart';
import 'package:egx/features/onboarding/presentation/widgets/sectors_step.dart';
import 'package:egx/features/onboarding/presentation/widgets/onboarding_success_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Stack(
        children: [
          // Same animated candlestick background as auth screens
          Positioned.fill(child: customBackground(context)),

          SafeArea(
            child: Column(
              children: [
                // ── Header: progress + skip ──
                Obx(() {
                  final step = controller.currentStep.value;
                  final isSuccess = step >= controller.totalSteps;
                  if (isSuccess) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Step indicator pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.surface.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: Text(
                                '${step + 1} / ${controller.totalSteps}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            // Skip (step 0 only)
                            if (step == 0)
                              GestureDetector(
                                onTap: controller.goToHome,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Skip',
                                        style: TextStyle(
                                          color: context.onBackground
                                              .withOpacity(0.4),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 11,
                                        color: context.onBackground.withOpacity(
                                          0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Continuous progress bar
                        _buildProgressBar(context, step),
                      ],
                    ),
                  );
                }),

                // ── Steps PageView ──
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      ExperienceStep(),
                      GoalStep(),
                      SectorsStep(),
                      OnboardingSuccessPage(),
                    ],
                  ),
                ),

                // ── Bottom Navigation ──
                Obx(() {
                  final step = controller.currentStep.value;
                  final isSuccess = step >= controller.totalSteps;
                  if (isSuccess) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: Row(
                      children: [
                        // Back button — glass ghost style
                        if (step > 0)
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: controller.prevStep,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: context.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.textFaint,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      color: context.onSurface.withOpacity(
                                        0.75,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (step > 0) const SizedBox(width: 14),

                        // Next / Confirm — primary gradient button
                        Expanded(
                          flex: step > 0 ? 2 : 1,
                          child: Obx(() {
                            final isSubmitting = controller.isSubmitting.value;
                            final isLast = step == controller.totalSteps - 1;
                            return Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: isSubmitting
                                    ? null
                                    : controller.nextStep,
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryLight,
                                        AppColors.primaryDark,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: isSubmitting
                                      ? CandlestickLoader(
                                          width: 40,
                                          height: 28,
                                          duration: const Duration(
                                            milliseconds: 800,
                                          ),
                                        )
                                      : Text(
                                          isLast ? 'Confirm  ✨' : 'Next',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, int step) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final progressWidth = totalWidth * ((step + 1) / controller.totalSteps);
        return Stack(
          children: [
            // Track
            Container(
              width: totalWidth,
              height: 5,
              decoration: BoxDecoration(
                color: context.onSurface.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              width: progressWidth,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
