// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constent/Theme Controller.dart';
import 'HomeScreen/home_page.dart';
import 'SplashScreen.dart';
import 'l10n_controller/CountryChangeController.dart';
import 'l10n_controller/language_change_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final LanguageChangeController languageController = Get.put(LanguageChangeController());
  final CurrencyController currencyController = Get.put(CurrencyController());

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        locale: languageController.appLocale.value,
        fallbackLocale: const Locale('en'),
        supportedLocales: const [
          Locale('en'), // English
          Locale('bn'), // Bengali
          Locale('hi'), // Hindi
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(),
        builder: (context, child) {
          return Builder(
            builder: (BuildContext context) {
              return child!;
            },
          );
        },
      ),
    );
  }
}

