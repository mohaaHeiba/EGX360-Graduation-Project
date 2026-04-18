import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// Grand Finale — same background as auth screens, Blaze-inspired minimalist layout.
class OnboardingSuccessPage extends GetView<OnboardingController> {
  const OnboardingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Lottie
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset(
                'assets/animations/congratulations.json',
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),

            const SizedBox(height: 32),

            // Subtle label
            Text(
              'YOUR VIRTUAL BALANCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 2.5,
              ),
            ),

            const SizedBox(height: 16),

            // Hero number with gradient
            ShaderMask(
              shaderCallback: (bounds) =>
                  context.gradients.logo.createShader(bounds),
              child: const Text(
                '100,000 EGP',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Description
            Text(
              'Your portfolio is ready.\nStart trading and test your strategy risk‑free!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.onSurface.withOpacity(0.6),
                height: 1.65,
              ),
            ),

            const Spacer(flex: 3),

            // CTA
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.goToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Trading',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
