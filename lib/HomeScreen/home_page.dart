import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppDrawer.dart';
import '../Constent/Theme Controller.dart';
import '../l10n_controller/CountryChangeController.dart';
import '../l10n_controller/CountrySelectionScreen.dart';
import '../l10n_controller/language.dart';
import 'Category/BankingCategory.dart';
import 'Category/EMICalculatorsCategory.dart';
import 'Category/InvestmentCalculatorsCategory.dart';
import 'Category/LoanCalculatorsCategory.dart';
import 'Category/RealEstateCategory.dart';
import 'Category/TaxCalculatorsCategory.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)?.financial_calculator ?? 'Financial Calculator'),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/translate.png',
              height: 24,
              width: 24,
            ),
            onPressed: () => Get.to(() => LanguageScreen()),
          ),
          IconButton(
            icon: Icon(Icons.public),
            onPressed: () => Get.to(() => CountrySelectionScreen()),
          ),
          Obx(() => IconButton(
            icon: Icon(themeController.isDarkMode.value ? Icons.light_mode : Icons.nights_stay),
            onPressed: () => themeController.toggleTheme(),
          )),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        EMICalculatorsCategory(),
                        LoanCalculatorsCategory(),
                        TaxCalculatorsCategory(),
                        BankingCategory(),
                        InvestmentCalculatorsCategory(),
                        RealEstateCategory(),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}