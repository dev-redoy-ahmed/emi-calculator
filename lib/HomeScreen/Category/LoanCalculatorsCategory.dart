import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import your localization class

import '../../SubCatagory/Loan/BalanceTransferCalculator.dart';
import '../../SubCatagory/Loan/BusinessLoanEMICalculator.dart';
import '../../SubCatagory/Loan/LoanComparisonCalculator.dart';
import '../../SubCatagory/Loan/LoanEligibilityCalculator.dart';
import '../../SubCatagory/Loan/PersonalLoanEMICalculator.dart';
import '../CategoryCard.dart';
import '../CategoryItem.dart';

class LoanCalculatorsCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      title: AppLocalizations.of(context)?.loanCalculators ?? 'Loan Calculators', // Localized title
      color: Colors.blue,
      icon: Icons.attach_money,
      items: [
        _buildLoanCalculatorItem(
            context, Icons.compare_arrows, AppLocalizations.of(context)?.loanComparison ?? 'Loan \nComparison'),
        _buildLoanCalculatorItem(
            context, Icons.check_circle_outline, AppLocalizations.of(context)?.loanEligibility ?? 'Loan \nEligibility'),
        _buildLoanCalculatorItem(
            context, Icons.person, AppLocalizations.of(context)?.personalLoanEmi ?? 'Personal \nLoan EMI'),
        _buildLoanCalculatorItem(
            context, Icons.business, AppLocalizations.of(context)?.businessLoanEmi ?? 'Business \nLoan EMI'),
        _buildLoanCalculatorItem(
            context, Icons.transform, AppLocalizations.of(context)?.balanceTransfer ?? 'Balance \nTransfer'),
      ],
    );
  }

  Widget _buildLoanCalculatorItem(BuildContext context, IconData icon, String label) {
    return CategoryItem(
      icon: icon,
      label: label,
      color: Colors.blue,
      onTap: () {
        Widget page;
        switch (label) {
          case 'Loan \nComparison':
            page = LoanComparisonCalculator();
            break;
          case 'Loan \nEligibility':
            page = LoanEligibilityCalculator();
            break;
          case 'Personal \nLoan EMI':
            page = PersonalLoanEMICalculator();
            break;
          case 'Business \nLoan EMI':
            page = BusinessLoanEMICalculator();
            break;
          case 'Balance \nTransfer':
            page = BalanceTransferCalculator();
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
