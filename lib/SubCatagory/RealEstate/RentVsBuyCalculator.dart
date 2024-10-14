import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class RentVsBuyCalculator extends StatefulWidget {
  @override
  _RentVsBuyCalculatorState createState() => _RentVsBuyCalculatorState();
}

class _RentVsBuyCalculatorState extends State<RentVsBuyCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController rentController = TextEditingController();
  TextEditingController homePriceController = TextEditingController();
  TextEditingController interestRateController = TextEditingController();
  TextEditingController downPaymentController = TextEditingController();
  TextEditingController propertyTaxController = TextEditingController();
  TextEditingController maintenanceController = TextEditingController();
  TextEditingController appreciationRateController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  bool showResults = false;
  double totalRentCost = 0;
  double totalHomeCost = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController

  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateRentVsBuy() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double monthlyRent = double.parse(rentController.text.replaceAll(',', ''));
      double homePrice = double.parse(homePriceController.text.replaceAll(',', ''));
      double annualInterestRate = double.parse(interestRateController.text) / 100;
      double downPayment = double.parse(downPaymentController.text.replaceAll(',', ''));
      double propertyTaxRate = double.parse(propertyTaxController.text) / 100;
      double maintenanceCost = double.parse(maintenanceController.text.replaceAll(',', ''));
      double appreciationRate = double.parse(appreciationRateController.text) / 100;
      int periodYears = int.parse(periodController.text);

      double loanAmount = homePrice - downPayment;
      int totalMonths = periodYears * 12;
      double monthlyInterestRate = annualInterestRate / 12;

      // Rent Calculation: Total rent for the period
      totalRentCost = monthlyRent * totalMonths;

      // Home Buying Calculation: Total cost over the period
      double mortgagePayment = loanAmount *
          (monthlyInterestRate * pow(1 + monthlyInterestRate, totalMonths)) /
          (pow(1 + monthlyInterestRate, totalMonths) - 1);

      double propertyTax = (homePrice * propertyTaxRate) * periodYears;
      double totalMaintenance = maintenanceCost * periodYears;
      double homeValueAfterAppreciation = homePrice * pow(1 + appreciationRate, periodYears);

      totalHomeCost = (mortgagePayment * totalMonths) + propertyTax + totalMaintenance - (homeValueAfterAppreciation - homePrice);

      setState(() {
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    rentController.clear();
    homePriceController.clear();
    interestRateController.clear();
    downPaymentController.clear();
    propertyTaxController.clear();
    maintenanceController.clear();
    appreciationRateController.clear();
    periodController.clear();
    setState(() {
      showResults = false;
      totalRentCost = 0;
      totalHomeCost = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.rent_vs_buy_calculator ?? 'Rent vs Buy Calculator'),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '(${currencyController.selectedCurrencyName.value})', // Currency name in AppBar
                style: TextStyle(fontSize: 18),
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildInputField(
                    AppLocalizations.of(context)?.monthly_rent ?? 'Monthly Rent',
                    rentController,
                    '\$1,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.home_price ?? 'Home Price',
                    homePriceController,
                    '\$200,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %',
                    interestRateController,
                    '3%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.down_payment ?? 'Down Payment',
                    downPaymentController,
                    '\$20,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.property_tax_rate ?? 'Property Tax Rate %',
                    propertyTaxController,
                    '1%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.maintenance_cost ?? 'Maintenance Cost (Yearly)',
                    maintenanceController,
                    '\$2,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.appreciation_rate ?? 'Appreciation Rate %',
                    appreciationRateController,
                    '3%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.period ?? 'Period (Years)',
                    periodController,
                    '15' // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateRentVsBuy, Colors.blue)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.reset ?? 'Reset', _reset, Colors.grey)),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
                if (showResults) _buildResultsTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isOptional = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: Get.height * 0.01), // Responsive margin
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.30, // Responsive width for label
            child: Text(label),
          ),
          Expanded(
            child: Container(
              height: 40, // Reduced fixed height
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade500), // Light hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced vertical padding
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14), // Responsive text size
                validator: (value) {
                  if (!isOptional && (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)?.enter_value ?? 'Please enter a value';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 40, // Reduced fixed height for buttons
      child: ElevatedButton(
        child: Text(
          label,
          style: TextStyle(fontSize: Get.textScaleFactor * 14), // Responsive text size
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 0), // Minimal vertical padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return Obx(() => Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        _buildTableRow(
          AppLocalizations.of(context)?.total_rent_cost ?? 'Total Rent Cost',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalRentCost)}',
        ),
        _buildTableRow(
          AppLocalizations.of(context)?.total_home_cost ?? 'Total Home Cost',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalHomeCost)}',
        ),
        _buildTableRow(
          totalRentCost > totalHomeCost
              ? AppLocalizations.of(context)?.renting_cheaper ?? 'Renting is cheaper'
              : AppLocalizations.of(context)?.buying_cheaper ?? 'Buying is cheaper',
          totalRentCost > totalHomeCost
              ? AppLocalizations.of(context)?.rent_savings ?? 'Renting saves'
              : AppLocalizations.of(context)?.buy_savings ?? 'Buying saves',
        ),
      ],
    ));
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(Get.width * 0.02), // Responsive padding
          child: Text(label),
        ),
        Padding(
          padding: EdgeInsets.all(Get.width * 0.02), // Responsive padding
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
