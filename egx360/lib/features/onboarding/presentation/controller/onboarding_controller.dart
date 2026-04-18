import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingController extends GetxController {
  final supabase = Supabase.instance.client;

  // ── State ──
  final currentStep = 0.obs;
  final experience = ''.obs;        // 'مبتدئ' / 'متوسط' / 'خبير'
  final goal = ''.obs;              // 'أمان' / 'متوازن' / 'مخاطرة'
  final selectedSectors = <String>[].obs;
  final isSubmitting = false.obs;

  // Total steps: 3 question screens + 1 success screen = 4 pages
  final totalSteps = 3;
  final pageController = PageController();

  // ── Navigation ──

  void nextStep() {
    if (!_validateCurrentStep()) return;

    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last question step → submit
      _submitAndShowSuccess();
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        if (experience.value.isEmpty) {
          customSnackbar(
            title: 'اختر مستوى خبرتك',
            message: 'لازم تختار مستوى خبرتك عشان نكمل',
            color: AppColors.warning,
          );
          return false;
        }
        return true;
      case 1:
        if (goal.value.isEmpty) {
          customSnackbar(
            title: 'اختر هدفك',
            message: 'لازم تختار هدف الاستثمار عشان نكمل',
            color: AppColors.warning,
          );
          return false;
        }
        return true;
      case 2:
        if (selectedSectors.isEmpty) {
          customSnackbar(
            title: 'اختر قطاع واحد على الأقل',
            message: 'اختار القطاعات اللي بتهمك',
            color: AppColors.warning,
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  // ── Supabase RPC + Success Transition ──

  Future<void> _submitAndShowSuccess() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    isSubmitting.value = true;

    try {
      await supabase.rpc('setup_user_portfolio', params: {
        'p_user_id': userId,
        'p_experience': experience.value,
        'p_goal': goal.value,
        'p_sectors': selectedSectors.toList(),
      });

      isSubmitting.value = false;

      // Navigate to success page (page index 3)
      currentStep.value = totalSteps; // beyond question steps
      pageController.animateToPage(
        totalSteps, // the 4th page (success)
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      isSubmitting.value = false;
      customSnackbar(
        title: 'حصل مشكلة',
        message: 'حاول تاني: $e',
        color: AppColors.error,
      );
    }
  }

  void goToHome() {
    Get.offAllNamed(AppPages.layoutPage);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
