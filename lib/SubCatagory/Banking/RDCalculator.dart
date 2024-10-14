import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // For localization

class RDCalculator extends StatefulWidget {
  @override
  _RDCalculatorState createState() => _RDCalculatorState();
}

class _RDCalculatorState extends State<RDCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController monthlyDepositController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  bool isYears = true;
  bool showResults = false;
  double maturityAmount = 0;
  double totalInterest = 0;
  double totalDeposits = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateRD() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double monthlyDeposit = double.parse(monthlyDepositController.text.replaceAll(',', ''));
      double annualInterest = double.parse(interestController.text) / 100;
      int period = int.parse(periodController.text);
      if (isYears) period *= 12;

      double monthlyInterest = annualInterest / 12;
      double rdFactor = (pow(1 + monthlyInterest, period) - 1) / monthlyInterest;
      double maturityValue = monthlyDeposit * rdFactor * (1 + monthlyInterest);

      double totalAmountDeposited = monthlyDeposit * period;
      double totalInterestEarned = maturityValue - totalAmountDeposited;

      setState(() {
        maturityAmount = maturityValue;
        totalInterest = totalInterestEarned;
        totalDeposits = totalAmountDeposited;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    monthlyDepositController.clear();
    interestController.clear();
    periodController.clear();
    setState(() {
      showResults = false;
      maturityAmount = 0;
      totalInterest = 0;
      totalDeposits = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.rd_calculator ?? 'RD Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildInputField(AppLocalizations.of(context)?.monthly_deposit ?? 'Monthly Deposit', monthlyDepositController, AppLocalizations.of(context)?.enter_monthly_deposit ?? 'Enter monthly deposit'),
                _buildInputField(AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %', interestController, AppLocalizations.of(context)?.enter_interest_rate ?? 'Enter interest rate'),
                _buildPeriodField(),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateRD, Colors.blue)),
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

  Widget _buildPeriodField() {
    return Container(
      margin: EdgeInsets.only(bottom: Get.height * 0.01),
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.30, // Responsive width for label
            child: Text(AppLocalizations.of(context)?.period ?? 'Period'),
          ),
          Expanded(
            child: Container(
              height: 40, // Reduced fixed height
              child: TextFormField(
                controller: periodController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: AppLocalizations.of(context)?.enter_period ?? 'Enter period',
                  hintStyle: TextStyle(color: Colors.grey.shade500), // Light hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced vertical padding
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14), // Responsive text size
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)?.enter_value ?? 'Please enter a value';
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(width: Get.width * 0.02),
          GestureDetector(
            onTap: () => setState(() => isYears = true),
            child: Text(
              AppLocalizations.of(context)?.years ?? 'Years',
              style: TextStyle(
                color: isYears ? Colors.blue : null,
                fontSize: Get.textScaleFactor * 14, // Responsive text size
              ),
            ),
          ),
          Text(' | '),
          GestureDetector(
            onTap: () => setState(() => isYears = false),
            child: Text(
              AppLocalizations.of(context)?.months ?? 'Months',
              style: TextStyle(
                color: !isYears ? Colors.blue : null,
                fontSize: Get.textScaleFactor * 14, // Responsive text size
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.results ?? 'Results',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          children: [
            _buildTableRow(AppLocalizations.of(context)?.maturity_value ?? 'Maturity Value', currencyFormatter.format(maturityAmount)),
            _buildTableRow(AppLocalizations.of(context)?.total_deposits ?? 'Total Deposits', currencyFormatter.format(totalDeposits)),
            _buildTableRow(AppLocalizations.of(context)?.total_interest ?? 'Total Interest', currencyFormatter.format(totalInterest)),
          ],
        ),
      ],
    );
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
