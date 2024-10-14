import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import your localization class

// Import the respective calculator pages
import '../../SubCatagory/RealEstate/HomeEquityLoanCalculator.dart';
import '../../SubCatagory/RealEstate/HomeLoanAffordabilityCalculator.dart';
import '../../SubCatagory/RealEstate/MortgageRefinanceCalculator.dart';
import '../../SubCatagory/RealEstate/RentVsBuyCalculator.dart';
import '../../SubCatagory/RealEstate/RentalYieldCalculator.dart';
import '../CategoryCard.dart';
import '../CategoryItem.dart';

class RealEstateCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      title: AppLocalizations.of(context)?.realEstateCategory ?? 'Real Estate & \nProperty', // Localized title
      color: Colors.green,
      icon: Icons.house,
      items: [
        _buildItem(context, Icons.home, AppLocalizations.of(context)?.homeLoanAffordability ?? 'Home Loan \nAffordability'),
        _buildItem(context, Icons.compare_arrows, AppLocalizations.of(context)?.rentVsBuy ?? 'Rent vs \nBuy'),
        _buildItem(context, Icons.attach_money, AppLocalizations.of(context)?.rentalYield ?? 'Rental \nYield'),
        _buildItem(context, Icons.account_balance_wallet, AppLocalizations.of(context)?.mortgageRefinance ?? 'Mortgage \nRefinance'),
        _buildItem(context, Icons.house_siding, AppLocalizations.of(context)?.homeEquityLoan ?? 'Home \nEquity Loan'),
      ],
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label) {
    return CategoryItem(
      icon: icon,
      label: label,
      color: Colors.green,
      onTap: () {
        Widget page;
        switch (label) {
          case 'Home Loan \nAffordability':
            page = HomeLoanAffordabilityCalculator();
            break;
          case 'Rent vs \nBuy':
            page = RentVsBuyCalculator();
            break;
          case 'Rental \nYield':
            page = RentalYieldCalculator();
            break;
          case 'Mortgage \nRefinance':
            page = MortgageRefinanceCalculator();
            break;
          case 'Home \nEquity Loan':
            page = HomeEquityLoanCalculator();
            break;
          default:
            page = Container(); // Default fallback
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
