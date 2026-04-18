import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class NewsTtsController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  var isSpeaking = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  void _initTts() async {
    // 1. تحديد المحرك (يفضل محرك جوجل لدعم أفضل للعربي)
    if (Platform.isAndroid) {
      await flutterTts.setEngine("com.google.android.tts");
    }

    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    // 2. معالجة الأخطاء (حل مشكلة Error -8)
    flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;

      // إذا كان الخطأ متعلق بعدم تثبيت ملفات اللغة
      if (msg.toString().contains("-8") ||
          msg.toString().contains("not installed")) {
        customSnackbar(
          title: 'تنبيه: ملفات الصوت',
          message:
              'يرجى تحميل بيانات الصوت العربية من إعدادات الهاتف لتشغيل هذه الميزة.',
          color: AppColors.error,
        );
      } else {
        customSnackbar(
          title: 'TTS Error',
          message: msg.toString(),
          color: AppColors.error,
        );
      }
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    if (isSpeaking.value) {
      await stop();
      return;
    }

    try {
      // 3. فحص هل اللغة العربية متوفرة على الجهاز
      bool isArabicSupported = await flutterTts.isLanguageAvailable("ar");

      // 4. تحديد اللغة بناءً على محتوى النص
      // سنقوم بفحص أول 20 حرف لتحديد اللغة الغالبة (عربي أم إنجليزي)
      bool startsWithArabic = RegExp(
        r'[\u0600-\u06FF]',
      ).hasMatch(text.substring(0, text.length > 20 ? 20 : text.length));

      if (startsWithArabic && !isArabicSupported) {
        customSnackbar(
          title: 'اللغة غير مدعومة',
          message:
              'جهازك لا يدعم نطق اللغة العربية حالياً، يرجى تحديث خدمات جوجل.',
          color: AppColors.error,
        );
        return;
      }

      await flutterTts.setLanguage(startsWithArabic ? "ar" : "en-US");

      isSpeaking.value = true;
      await flutterTts.speak(text);
    } catch (e) {
      isSpeaking.value = false;
      print("TTS Exception: $e");
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
    isSpeaking.value = false;
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        "Error",
        "Could not launch url",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.candleGreen,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
