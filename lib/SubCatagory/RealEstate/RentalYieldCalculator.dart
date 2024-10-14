import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class RentalYieldCalculator extends StatefulWidget {
  @override
  _RentalYieldCalculatorState createState() => _RentalYieldCalculatorState();
}

class _RentalYieldCalculatorState extends State<RentalYieldCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController monthlyRentController = TextEditingController();
  TextEditingController propertyPriceController = TextEditingController();
  TextEditingController otherExpensesController = TextEditingController();

  bool showResults = false;
  double annualRentalIncome = 0;
  double rentalYield = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController

  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateRentalYield() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double monthlyRent = double.parse(monthlyRentController.text.replaceAll(',', ''));
      double propertyPrice = double.parse(propertyPriceController.text.replaceAll(',', ''));
      double otherExpenses = double.parse(otherExpensesController.text.replaceAll(',', ''));

      annualRentalIncome = (monthlyRent * 12) - otherExpenses;

      if (propertyPrice > 0) {
        rentalYield = (annualRentalIncome / propertyPrice) * 100;
      }

      setState(() {
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    monthlyRentController.clear();
    propertyPriceController.clear();
    otherExpensesController.clear();
    setState(() {
      showResults = false;
      annualRentalIncome = 0;
      rentalYield = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.rental_yield_calculator ?? 'Rental Yield Calculator'),
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
                    monthlyRentController,
                    '\$1,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.property_purchase_price ?? 'Property Purchase Price',
                    propertyPriceController,
                    '\$200,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.other_annual_expenses ?? 'Other Annual Expenses',
                    otherExpensesController,
                    '\$5,000' // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateRentalYield, Colors.blue)),
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
          AppLocalizations.of(context)?.annual_rental_income ?? 'Annual Rental Income',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(annualRentalIncome)}',
        ),
        _buildTableRow(
          AppLocalizations.of(context)?.rental_yield ?? 'Rental Yield',
          '${numberFormatter.format(rentalYield)}%',
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
