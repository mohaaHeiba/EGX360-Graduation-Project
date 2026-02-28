import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class NewsSummaryController extends GetxController {
  late final NewsSummaryEntity summary;
  final FlutterTts _flutterTts = FlutterTts();
  final RxBool isSpeaking = false.obs;

  @override
  void onInit() {
    super.onInit();
    summary = Get.arguments as NewsSummaryEntity;
    _initTts();
  }

  @override
  void onClose() {
    _flutterTts.stop();
    super.onClose();
  }

  /// Initialize Text-to-Speech with Arabic and English support
  Future<void> _initTts() async {
    bool isArabicAvailable = await _flutterTts.isLanguageAvailable("ar");

    if (isArabicAvailable) {
      await _flutterTts.setLanguage("ar");
    } else {
      await _flutterTts.setLanguage("en-US");
    }

    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setCompletionHandler(() {
      if (!isSpeaking.value) {}
    });

    _flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      print("TTS Error: $msg");
      customSnackbar(
        title: 'Alert',
        message: 'You need to download Arabic language on your phone',
        color: AppColors.warning,
      );
    });
  }

  /// Toggle text-to-speech playback
  /// Handles both Arabic and English text intelligently and skips garbage symbols
  Future<void> toggleSpeech() async {
    if (isSpeaking.value) {
      await _flutterTts.stop();
      isSpeaking.value = false;
      return;
    }

    isSpeaking.value = true;

    // Regex splits text into English chunks OR Arabic/Number chunks
    final RegExp langRegex = RegExp(
      r'([a-zA-Z0-9\s]+)|([\u0600-\u06FF\s0-9%]+)',
    );
    final matches = langRegex.allMatches(summary.summary);

    for (var match in matches) {
      // If user stopped playback, break the loop immediately
      if (!isSpeaking.value) break;

      String chunk = match.group(0) ?? "";

      // 1. Basic cleaning: trim whitespace
      if (chunk.trim().isEmpty) continue;

      // 2. Smart Check: Does this chunk contain actual speakable content?
      // Matches any Letter (Ar/En) or Number.
      bool hasSpeakableContent = RegExp(
        r'[a-zA-Z\u0600-\u06FF0-9]',
      ).hasMatch(chunk);

      // If it's just symbols (like *&^% or _), skip it
      if (!hasSpeakableContent) continue;

      // 3. Clean internal symbols: Remove anything that isn't a word char, space, or %
      // This cleans "Text!@#" to "Text"
      chunk = chunk.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF0-9%]'), '');

      // Detect language and switch TTS accordingly
      bool isEnglish = RegExp(r'[a-zA-Z]').hasMatch(chunk);
      await _flutterTts.setLanguage(isEnglish ? "en-US" : "ar");

      // Speak and wait for completion (handled by awaitSpeakCompletion(true) in init)
      await _flutterTts.speak(chunk);
    }

    isSpeaking.value = false;
  }
}
