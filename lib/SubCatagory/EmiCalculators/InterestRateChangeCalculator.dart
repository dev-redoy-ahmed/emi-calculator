import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InterestRateChangeCalculator extends StatefulWidget {
  @override
  _InterestRateChangeCalculatorState createState() => _InterestRateChangeCalculatorState();
}

class _InterestRateChangeCalculatorState extends State<InterestRateChangeCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController originalInterestController = TextEditingController();
  TextEditingController newInterestController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  bool isYears = true;
  bool showResults = false;
  double originalEMI = 0;
  double newEMI = 0;
  double emiDifference = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateInterestRateChange() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));
      double originalInterest = double.parse(originalInterestController.text) / 12 / 100;
      double newInterest = double.parse(newInterestController.text) / 12 / 100;
      int period = int.parse(periodController.text);
      if (isYears) period *= 12;

      double emiOriginal = (amount * originalInterest * pow((1 + originalInterest), period)) /
          (pow((1 + originalInterest), period) - 1);
      double emiNew = (amount * newInterest * pow((1 + newInterest), period)) /
          (pow((1 + newInterest), period) - 1);
      double difference = emiNew - emiOriginal;

      setState(() {
        originalEMI = emiOriginal;
        newEMI = emiNew;
        emiDifference = difference;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    amountController.clear();
    originalInterestController.clear();
    newInterestController.clear();
    periodController.clear();
    setState(() {
      showResults = false;
      originalEMI = 0;
      newEMI = 0;
      emiDifference = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.interest_rate_change_calculator ?? 'Interest Rate Change Calculator'),
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
                  AppLocalizations.of(context)?.loan_amount ?? 'Loan Amount',
                  amountController,
                  AppLocalizations.of(context)?.enter_amount ?? 'Enter loan amount',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.original_interest_rate ?? 'Original Interest Rate %',
                  originalInterestController,
                  AppLocalizations.of(context)?.enter_interest ?? 'Enter original interest rate',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.new_interest_rate ?? 'New Interest Rate %',
                  newInterestController,
                  AppLocalizations.of(context)?.enter_new_interest ?? 'Enter new interest rate',
                ),
                _buildPeriodField(),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateInterestRateChange, Colors.blue)),
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

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Container(
      margin: EdgeInsets.only(bottom: Get.height * 0.01), // Responsive margin
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.40, // Adjusted responsive width for label
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
                  if (value == null || value.isEmpty) {
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
            width: Get.width * 0.40, // Responsive width for label
            child: Text(AppLocalizations.of(context)?.loan_period ?? 'Loan Period'),
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
                  hintText: AppLocalizations.of(context)?.enter_period ?? 'Enter loan period',
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
    return Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        _buildTableRow(AppLocalizations.of(context)?.original_emi ?? 'Original EMI', currencyFormatter.format(originalEMI)),
        _buildTableRow(AppLocalizations.of(context)?.new_emi ?? 'New EMI', currencyFormatter.format(newEMI)),
        _buildTableRow(AppLocalizations.of(context)?.emi_difference ?? 'EMI Difference', currencyFormatter.format(emiDifference)),
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
