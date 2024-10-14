import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // For localization

class PPFCalculator extends StatefulWidget {
  @override
  _PPFCalculatorState createState() => _PPFCalculatorState();
}

class _PPFCalculatorState extends State<PPFCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController yearlyContributionController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController(text: '15'); // Default is 15 years for PPF

  bool showResults = false;
  double maturityAmount = 0;
  double totalInterest = 0;
  double totalContribution = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculatePPF() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double yearlyContribution = double.parse(yearlyContributionController.text.replaceAll(',', ''));
      double annualInterest = double.parse(interestController.text) / 100;
      int period = int.parse(periodController.text); // PPF tenure

      double maturityValue = 0;

      // Compound Interest for PPF: A = P * [(1 + r)^t - 1] / r
      for (int i = 1; i <= period; i++) {
        maturityValue += yearlyContribution * pow(1 + annualInterest, period - i + 1);
      }

      double totalAmountDeposited = yearlyContribution * period;
      double totalInterestEarned = maturityValue - totalAmountDeposited;

      setState(() {
        maturityAmount = maturityValue;
        totalInterest = totalInterestEarned;
        totalContribution = totalAmountDeposited;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    yearlyContributionController.clear();
    interestController.clear();
    periodController.text = '15'; // Reset to default PPF tenure
    setState(() {
      showResults = false;
      maturityAmount = 0;
      totalInterest = 0;
      totalContribution = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.ppf_calculator ?? 'PPF Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildInputField(AppLocalizations.of(context)?.yearly_contribution ?? 'Yearly Contribution', yearlyContributionController, AppLocalizations.of(context)?.enter_yearly_contribution ?? 'Enter yearly contribution'),
                _buildInputField(AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %', interestController, AppLocalizations.of(context)?.enter_interest_rate ?? 'Enter interest rate'),
                _buildInputField(AppLocalizations.of(context)?.period_years ?? 'Period (Years)', periodController, AppLocalizations.of(context)?.enter_period ?? 'Enter period (default 15 years)'),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculatePPF, Colors.blue)),
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
            _buildTableRow(AppLocalizations.of(context)?.maturity_amount ?? 'Maturity Amount', currencyFormatter.format(maturityAmount)),
            _buildTableRow(AppLocalizations.of(context)?.total_contribution ?? 'Total Contribution', currencyFormatter.format(totalContribution)),
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
