import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum ThemeModeSelection { light, dark, system }

enum LanguageSelection { arabic, english }

class ThemeController extends GetxController {
  final themes = ['dark', 'light', 'system'];
  final box = GetStorage();

  final Rx<ThemeModeSelection> selectedMode = ThemeModeSelection.system.obs;

  void loadTheme() {
    final savedTheme = box.read('savedTheme');
    if (savedTheme != null && themes.contains(savedTheme)) {
      switch (savedTheme) {
        case 'light':
          selectedMode.value = ThemeModeSelection.light;
          Get.changeThemeMode(ThemeMode.light);
          break;
        case 'dark':
          selectedMode.value = ThemeModeSelection.dark;
          Get.changeThemeMode(ThemeMode.dark);
          break;
        default:
          selectedMode.value = ThemeModeSelection.system;
          Get.changeThemeMode(ThemeMode.system);
      }
    } else {
      selectedMode.value = ThemeModeSelection.system;
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  void selectMode(ThemeModeSelection mode) {
    selectedMode.value = mode;

    switch (mode) {
      case ThemeModeSelection.light:
        box.write('savedTheme', 'light');
        Get.changeThemeMode(ThemeMode.light);
        break;
      case ThemeModeSelection.dark:
        box.write('savedTheme', 'dark');
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        box.write('savedTheme', 'system');
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  // ----------------(Language) ----------------

  final languages = ['arabic', 'english'];

  final Rx<LanguageSelection> selectedLanguage = LanguageSelection.arabic.obs;

  void loadLanguage() {
    final savedLanguageCode = box.read('savedLanguage');
    Locale newLocale;

    if (savedLanguageCode == 'arabic') {
      selectedLanguage.value = LanguageSelection.arabic;
      newLocale = const Locale('ar');
    } else if (savedLanguageCode == 'english') {
      selectedLanguage.value = LanguageSelection.english;
      newLocale = const Locale('en');
    } else {
      final deviceLocale = Get.deviceLocale;
      final isEnglish =
          deviceLocale?.languageCode.toLowerCase().startsWith('en') ?? false;

      if (isEnglish) {
        selectedLanguage.value = LanguageSelection.english;
        newLocale = const Locale('en');
      } else {
        selectedLanguage.value = LanguageSelection.arabic;
        newLocale = const Locale('ar');
      }
    }

    Get.updateLocale(newLocale);
  }

  void selectLanguage(LanguageSelection language) {
    selectedLanguage.value = language;
    Locale newLocale;
    String languageCodeToSave;

    switch (language) {
      case LanguageSelection.arabic:
        languageCodeToSave = 'arabic';
        newLocale = const Locale('ar');
        break;
      case LanguageSelection.english:
        languageCodeToSave = 'english';
        newLocale = const Locale('en');
        break;
    }

    box.write('savedLanguage', languageCodeToSave);
    Get.updateLocale(newLocale);
  }

  // ----------------(Initialization) ----------------

  @override
  void onInit() {
    super.onInit();
    loadTheme();
    loadLanguage();
  }
}
