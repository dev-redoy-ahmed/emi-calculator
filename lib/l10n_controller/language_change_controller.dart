import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController extends GetxController {
  var appLocale = Locale('en').obs; // Observable Locale

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  void _loadSavedLanguage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String languageCode = sp.getString('language_code') ?? 'en'; // Default to English
    appLocale.value = Locale(languageCode);
  }

  // Change language and save the preference
  void changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    appLocale.value = type;

    await sp.setString('language_code', type.languageCode);

    // Update the app's locale
    Get.updateLocale(appLocale.value);
  }
}
