import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import your localization class

import '../../SubCatagory/Banking/CompoundInterestCalculator.dart';
import '../../SubCatagory/Banking/CreditCardCalculator.dart';
import '../../SubCatagory/Banking/CurrentAccountCalculator.dart';
import '../../SubCatagory/Banking/FDCalculator.dart';
import '../../SubCatagory/Banking/PPFCalculator.dart';
import '../../SubCatagory/Banking/RDCalculator.dart';
import '../../SubCatagory/Banking/SavingsCalculator.dart';
import '../CategoryCard.dart';
import '../CategoryItem.dart';

class BankingCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      title: AppLocalizations.of(context)?.banking ?? 'Banking', // Localized title
      color: Colors.blue,
      icon: Icons.account_balance,
      items: [
        _buildItem(context, Icons.calculate, AppLocalizations.of(context)?.rdCalculator ?? 'RD \nCalculator'),
        _buildItem(context, Icons.calculate, AppLocalizations.of(context)?.fdCalculator ?? 'FD \nCalculator'),
        _buildItem(context, Icons.percent, AppLocalizations.of(context)?.ppf ?? 'PPF'),
        _buildItem(context, Icons.calculate_outlined, AppLocalizations.of(context)?.compoundInterest ?? 'Compound \nInterest'),
        _buildItem(context, Icons.savings, AppLocalizations.of(context)?.savings ?? 'Savings'),
        _buildItem(context, Icons.credit_card, AppLocalizations.of(context)?.creditCard ?? 'Credit \nCard'),
        _buildItem(context, Icons.account_balance, AppLocalizations.of(context)?.currentAccount ?? 'Current \nAccount'),
      ],
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label) {
    return CategoryItem(
      icon: icon,
      label: label,
      color: Colors.blue,
      onTap: () {
        Widget page;
        switch (label) {
          case 'RD \nCalculator':
            page = RDCalculator(); // Navigate to RD Calculator
            break;
          case 'FD \nCalculator':
            page = FDCalculator(); // Navigate to FD Calculator
            break;
          case 'PPF':
            page = PPFCalculator(); // Navigate to PPF Calculator
            break;
          case 'Compound \nInterest':
            page = CompoundInterestCalculator(); // Navigate to Compound Interest Calculator
            break;
          case 'Savings':
            page = SavingsCalculator(); // Navigate to Savings Calculator
            break;
          case 'Credit \nCard':
            page = CreditCardCalculator(); // Navigate to Credit Card Calculator
            break;
          case 'Current \nAccount':
            page = CurrentAccountCalculator(); // Navigate to Current Account Calculator
            break;
          default:
            page = Container(); // Fallback in case label doesn't match
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
