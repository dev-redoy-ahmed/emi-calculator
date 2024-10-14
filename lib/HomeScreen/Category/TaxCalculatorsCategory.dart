import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization class

import '../../SubCatagory/Text/GSTCalculator.dart';
import '../../SubCatagory/Text/IncomeTaxCalculator.dart';
import '../../SubCatagory/Text/NetInvestmentIncomeTaxCalculator.dart';
import '../../SubCatagory/Text/TaxSavingsCalculator.dart';
import '../../SubCatagory/Text/VATCalculator.dart';
import '../CategoryCard.dart';
import '../CategoryItem.dart';

class TaxCalculatorsCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      title: AppLocalizations.of(context)?.taxCalculators ?? 'Tax Calculators', // Localized title
      color: Colors.green,
      icon: Icons.account_balance_wallet,
      items: [
        _buildTaxCalculatorItem(context, Icons.attach_money, AppLocalizations.of(context)?.incomeTax ?? 'Income \nTax'),
        _buildTaxCalculatorItem(context, Icons.receipt, AppLocalizations.of(context)?.gstCalculator ?? 'GST \nCalculator'),
        _buildTaxCalculatorItem(context, Icons.percent, AppLocalizations.of(context)?.vatCalculator ?? 'VAT \nCalculator'),
        _buildTaxCalculatorItem(context, Icons.savings, AppLocalizations.of(context)?.taxSavings ?? 'Tax \nSavings'),
        _buildTaxCalculatorItem(context, Icons.pie_chart, AppLocalizations.of(context)?.netInvestmentIncomeTax ?? 'Net Investment \nIncome Tax'),
      ],
    );
  }

  Widget _buildTaxCalculatorItem(BuildContext context, IconData icon, String label) {
    return CategoryItem(
      icon: icon,
      label: label,
      color: Colors.green,
      onTap: () {
        Widget page;
        switch (label) {
          case 'Income \nTax':
            page = IncomeTaxCalculator();
            break;
          case 'GST \nCalculator':
            page = GSTCalculator();
            break;
          case 'Tax \nSavings':
            page = TaxSavingsCalculator();
            break;
          case 'Net Investment \nIncome Tax':
            page = NetInvestmentIncomeTaxCalculator();
            break;
          case 'VAT \nCalculator':
            page = VATCalculator();
            break;
          default:
            page = Container(); // Fallback widget
        }
        Get.to(
              () => page,
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300),
        );
      },
    );
  }
}
