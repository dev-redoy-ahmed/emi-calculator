import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import your localization class

import '../../SubCatagory/EmiCalculators/AdvancedEMICalculator.dart';
import '../../SubCatagory/EmiCalculators/FlatRateEMICalculator.dart';
import '../../SubCatagory/EmiCalculators/InterestRateChangeCalculator.dart';
import '../../SubCatagory/EmiCalculators/MoratoriumEMICalculator.dart';
import '../../SubCatagory/EmiCalculators/PrePaymentCalculator.dart';
import '../../SubCatagory/EmiCalculators/QuickEMICalculator.dart';
import '../../SubCatagory/EmiCalculators/StepDownEMICalculator.dart';
import '../../SubCatagory/EmiCalculators/StepUpEMICalculator.dart';
import '../../SubCatagory/EmiCalculators/emi.dart';
import '../CategoryCard.dart';
import '../CategoryItem.dart';

class EMICalculatorsCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      title: AppLocalizations.of(context)?.emiCalculators ?? 'EMI Calculators', // Localized title
      color: Colors.orange,
      icon: Icons.calculate,
      items: [
        _buildItem(context, Icons.calculate_outlined, AppLocalizations.of(context)?.emiCalculator ?? 'EMI \nCalculators'),
        _buildItem(context, Icons.trending_up, AppLocalizations.of(context)?.advancedEmi ?? 'Advanced \nEMI'),
        _buildItem(context, Icons.flash_on, AppLocalizations.of(context)?.quickEmi ?? 'Quick \nEMI'),
        _buildItem(context, Icons.pause_circle_outline, AppLocalizations.of(context)?.moratoriumEmi ?? 'Moratorium \nEMI'),
        _buildItem(context, Icons.money_off, AppLocalizations.of(context)?.prePayment ?? 'Pre-payment'),
        _buildItem(context, Icons.swap_vert, AppLocalizations.of(context)?.interestRate ?? 'Interest \nRate'),
        _buildItem(context, Icons.trending_up, AppLocalizations.of(context)?.stepUpEmi ?? 'Step-up \nEMI'),
        _buildItem(context, Icons.trending_down, AppLocalizations.of(context)?.stepDownEmi ?? 'Step-down \nEMI'),
        _buildItem(context, Icons.drag_handle, AppLocalizations.of(context)?.flatRateEmi ?? 'Flat \nRate EMI'),
      ],
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label) {
    return CategoryItem(
      icon: icon,
      label: label,
      color: Colors.orange,
      onTap: () {
        Widget page;
        switch (label) {
          case 'EMI \nCalculators':
            page = EMICalculator();
            break;
          case 'Advanced \nEMI':
            page = AdvancedEMICalculator();
            break;
          case 'Quick \nEMI':
            page = QuickCalculator();
            break;
          case 'Moratorium \nEMI':
            page = MoratoriumEMICalculator();
            break;
          case 'Step-up \nEMI':
            page = StepUpEMICalculator();
            break;
          case 'Step-down \nEMI':
            page = StepDownEMICalculator();
            break;
          case 'Flat \nRate EMI':
            page = FlatRateEMICalculator();
            break;
          case 'Pre-payment':
            page = PrePaymentCalculator();
            break;
          case 'Interest \nRate':
            page = InterestRateChangeCalculator();
            break;
          default:
            page = Container(); // Fallback widget if label doesn't match
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
