import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import your localization class

import '../../SubCatagory/Investment/CAGRCalculator.dart';
import '../../SubCatagory/Investment/DividendYieldCalculator.dart';
import '../../SubCatagory/Investment/LumpSumInvestmentCalculator.dart';
import '../../SubCatagory/Investment/ROICalculator.dart';
import '../../SubCatagory/Investment/SIPCalculator.dart';
import '../CategoryCard.dart';
import '../CategoryItem.dart';

class InvestmentCalculatorsCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      title: AppLocalizations.of(context)?.investment ?? 'Investment', // Localized title
      color: Colors.purple,
      icon: Icons.trending_up,
      items: [
        _buildInvestmentCalculatorItem(
            context, Icons.savings, AppLocalizations.of(context)?.sipCalculator ?? 'SIP \nCalculator'),
        _buildInvestmentCalculatorItem(
            context, Icons.attach_money, AppLocalizations.of(context)?.roiCalculator ?? 'ROI \nCalculator'),
        _buildInvestmentCalculatorItem(
            context, Icons.money, AppLocalizations.of(context)?.lumpSumInvestment ?? 'Lump Sum \nInvestment'),
        _buildInvestmentCalculatorItem(
            context, Icons.bar_chart, AppLocalizations.of(context)?.cagrCalculator ?? 'CAGR \nCalculator'),
        _buildInvestmentCalculatorItem(
            context, Icons.pie_chart, AppLocalizations.of(context)?.dividendYield ?? 'Dividend \nYield'),
      ],
    );
  }

  Widget _buildInvestmentCalculatorItem(BuildContext context, IconData icon, String label) {
    return CategoryItem(
      icon: icon,
      label: label,
      color: Colors.purple,
      onTap: () {
        Widget page;
        switch (label) {
          case 'SIP \nCalculator':
            page = SIPCalculator();
            break;
          case 'ROI \nCalculator':
            page = ROICalculator();
            break;
          case 'Lump Sum \nInvestment':
            page = LumpSumInvestmentCalculator();
            break;
          case 'CAGR \nCalculator':
            page = CAGRCalculator();
            break;
          case 'Dividend \nYield':
            page = DividendYieldCalculator();
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
