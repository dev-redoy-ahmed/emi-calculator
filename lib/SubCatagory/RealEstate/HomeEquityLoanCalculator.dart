import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class HomeEquityLoanCalculator extends StatefulWidget {
  @override
  _HomeEquityLoanCalculatorState createState() => _HomeEquityLoanCalculatorState();
}

class _HomeEquityLoanCalculatorState extends State<HomeEquityLoanCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController homeValueController = TextEditingController();
  TextEditingController mortgageBalanceController = TextEditingController();
  TextEditingController loanToValueController = TextEditingController();

  bool showResults = false;
  double availableHomeEquity = 0;
  double maxLoanAmount = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateHomeEquityLoan() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double homeValue = double.parse(homeValueController.text.replaceAll(',', ''));
      double mortgageBalance = double.parse(mortgageBalanceController.text.replaceAll(',', ''));
      double loanToValueRatio = double.parse(loanToValueController.text) / 100;

      // Calculate available home equity and the maximum loan amount
      availableHomeEquity = homeValue * loanToValueRatio;
      maxLoanAmount = availableHomeEquity - mortgageBalance;

      setState(() {
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    homeValueController.clear();
    mortgageBalanceController.clear();
    loanToValueController.clear();
    setState(() {
      showResults = false;
      availableHomeEquity = 0;
      maxLoanAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.home_equity_loan_calculator ?? 'Home Equity Loan Calculator'),
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
                  AppLocalizations.of(context)?.home_value ?? 'Home Value',
                  homeValueController,
                  '\$500,000', // Example formatted hint
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.mortgage_balance ?? 'Mortgage Balance',
                  mortgageBalanceController,
                  '\$200,000', // Example formatted hint
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.loan_to_value_ratio ?? 'Loan-to-Value Ratio %',
                  loanToValueController,
                  '80%', // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateHomeEquityLoan, Colors.blue),
                    ),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(
                      child: _buildButton(AppLocalizations.of(context)?.reset ?? 'Reset', _reset, Colors.grey),
                    ),
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formattedText = _formatNumberWithCommas(newValue.text);
                    return newValue.copyWith(text: formattedText);
                  }),
                ],
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
          AppLocalizations.of(context)?.available_home_equity ?? 'Available Home Equity',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(availableHomeEquity)}',
        ),
        _buildTableRow(
          AppLocalizations.of(context)?.maximum_loan_amount ?? 'Maximum Loan Amount',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(maxLoanAmount)}',
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

  String _formatNumberWithCommas(String value) {
    if (value == '') return '';
    final parts = value.split('.');
    final integerPart = parts[0].replaceAll(',', '');  // Remove commas before formatting
    final formattedIntegerPart = NumberFormat('#,##0').format(int.parse(integerPart));

    // Return integer part with commas, and append the decimal part if it exists
    if (parts.length > 1) {
      return '$formattedIntegerPart.${parts[1]}';  // Include decimal part
    } else {
      return formattedIntegerPart;  // Only integer part
    }
  }
}
