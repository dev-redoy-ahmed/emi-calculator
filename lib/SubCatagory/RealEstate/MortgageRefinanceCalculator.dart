import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class MortgageRefinanceCalculator extends StatefulWidget {
  @override
  _MortgageRefinanceCalculatorState createState() => _MortgageRefinanceCalculatorState();
}

class _MortgageRefinanceCalculatorState extends State<MortgageRefinanceCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController currentLoanAmountController = TextEditingController();
  TextEditingController currentInterestRateController = TextEditingController();
  TextEditingController currentTermController = TextEditingController();
  TextEditingController newLoanAmountController = TextEditingController();
  TextEditingController newInterestRateController = TextEditingController();
  TextEditingController newTermController = TextEditingController();
  TextEditingController closingCostController = TextEditingController();

  bool showResults = false;
  double currentMonthlyPayment = 0;
  double newMonthlyPayment = 0;
  double totalSavings = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController

  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateRefinance() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double currentLoanAmount = double.parse(currentLoanAmountController.text.replaceAll(',', ''));
      double currentInterestRate = double.parse(currentInterestRateController.text) / 100;
      int currentTermMonths = int.parse(currentTermController.text) * 12;

      double newLoanAmount = double.parse(newLoanAmountController.text.replaceAll(',', ''));
      double newInterestRate = double.parse(newInterestRateController.text) / 100;
      int newTermMonths = int.parse(newTermController.text) * 12;

      double closingCost = double.parse(closingCostController.text.replaceAll(',', ''));

      double currentMonthlyInterestRate = currentInterestRate / 12;
      double newMonthlyInterestRate = newInterestRate / 12;

      // Calculate the current mortgage monthly payment
      currentMonthlyPayment = currentLoanAmount *
          (currentMonthlyInterestRate * pow(1 + currentMonthlyInterestRate, currentTermMonths)) /
          (pow(1 + currentMonthlyInterestRate, currentTermMonths) - 1);

      // Calculate the new mortgage monthly payment
      newMonthlyPayment = newLoanAmount *
          (newMonthlyInterestRate * pow(1 + newMonthlyInterestRate, newTermMonths)) /
          (pow(1 + newMonthlyInterestRate, newTermMonths) - 1);

      // Calculate total savings or cost over the new loan term including closing costs
      double totalCostWithRefinance = (newMonthlyPayment * newTermMonths) + closingCost;
      double totalCostWithoutRefinance = currentMonthlyPayment * currentTermMonths;

      totalSavings = totalCostWithoutRefinance - totalCostWithRefinance;

      setState(() {
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    currentLoanAmountController.clear();
    currentInterestRateController.clear();
    currentTermController.clear();
    newLoanAmountController.clear();
    newInterestRateController.clear();
    newTermController.clear();
    closingCostController.clear();
    setState(() {
      showResults = false;
      currentMonthlyPayment = 0;
      newMonthlyPayment = 0;
      totalSavings = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.mortgage_refinance_calculator ?? 'Mortgage Refinance Calculator'),
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
                    AppLocalizations.of(context)?.current_loan_amount ?? 'Current Loan Amount',
                    currentLoanAmountController,
                    '\$200,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.current_interest_rate ?? 'Current Interest Rate %',
                    currentInterestRateController,
                    '5%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.current_term_years ?? 'Current Term (Years)',
                    currentTermController,
                    '30 years' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.new_loan_amount ?? 'New Loan Amount',
                    newLoanAmountController,
                    '\$150,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.new_interest_rate ?? 'New Interest Rate %',
                    newInterestRateController,
                    '3%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.new_term_years ?? 'New Term (Years)',
                    newTermController,
                    '20 years' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.closing_costs ?? 'Closing Costs',
                    closingCostController,
                    '\$3,000' // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateRefinance, Colors.blue)),
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
          AppLocalizations.of(context)?.current_monthly_payment ?? 'Current Monthly Payment',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(currentMonthlyPayment)}',
        ),
        _buildTableRow(
          AppLocalizations.of(context)?.new_monthly_payment ?? 'New Monthly Payment',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(newMonthlyPayment)}',
        ),
        _buildTableRow(
          totalSavings > 0 ? AppLocalizations.of(context)?.total_savings ?? 'Total Savings' : AppLocalizations.of(context)?.total_cost ?? 'Total Cost',
          '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalSavings.abs())}',
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
