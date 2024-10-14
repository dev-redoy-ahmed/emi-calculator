import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class HomeLoanAffordabilityCalculator extends StatefulWidget {
  @override
  _HomeLoanAffordabilityCalculatorState createState() => _HomeLoanAffordabilityCalculatorState();
}

class _HomeLoanAffordabilityCalculatorState extends State<HomeLoanAffordabilityCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController incomeController = TextEditingController();
  TextEditingController expensesController = TextEditingController();
  TextEditingController interestRateController = TextEditingController();
  TextEditingController loanTermController = TextEditingController();

  bool showResults = false;
  double maxLoanAmount = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Currency Controller

  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  // Assumes a safe Debt-to-Income ratio of 36%
  double debtToIncomeRatio = 0.36;

  void _calculateAffordability() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double monthlyIncome = double.parse(incomeController.text.replaceAll(',', ''));
      double monthlyExpenses = double.parse(expensesController.text.replaceAll(',', ''));
      double annualInterestRate = double.parse(interestRateController.text) / 100;
      int loanTermYears = int.parse(loanTermController.text);

      double monthlyInterestRate = annualInterestRate / 12;
      int totalMonths = loanTermYears * 12;

      // Calculate the maximum affordable monthly mortgage payment
      double affordableMonthlyPayment = (monthlyIncome - monthlyExpenses) * debtToIncomeRatio;

      // Calculate maximum loan amount using mortgage formula
      double maxLoan = affordableMonthlyPayment *
          ((pow(1 + monthlyInterestRate, totalMonths) - 1) / (monthlyInterestRate * pow(1 + monthlyInterestRate, totalMonths)));

      setState(() {
        maxLoanAmount = maxLoan;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    incomeController.clear();
    expensesController.clear();
    interestRateController.clear();
    loanTermController.clear();
    setState(() {
      showResults = false;
      maxLoanAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.home_loan_affordability_calculator ?? 'Home Loan Affordability Calculator'),
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
                    AppLocalizations.of(context)?.monthly_income ?? 'Monthly Income',
                    incomeController,
                    '\$5,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.monthly_expenses ?? 'Monthly Expenses',
                    expensesController,
                    '\$2,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %',
                    interestRateController,
                    '5%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.loan_term_years ?? 'Loan Term (Years)',
                    loanTermController,
                    '30 years' // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateAffordability, Colors.blue)),
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
}
