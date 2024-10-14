import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // Import localization

class FDCalculator extends StatefulWidget {
  @override
  _FDCalculatorState createState() => _FDCalculatorState();
}

class _FDCalculatorState extends State<FDCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController principalController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  bool isYears = true;
  bool isCompoundMonthly = true;
  bool showResults = false;
  double maturityAmount = 0;
  double totalInterest = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateFD() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double principal = double.parse(principalController.text.replaceAll(',', ''));
      double annualInterest = double.parse(interestController.text) / 100;
      int period = int.parse(periodController.text);
      if (isYears) period *= 12;

      double interestRate = annualInterest / (isCompoundMonthly ? 12 : 1); // Monthly or annual compounding
      int compoundFrequency = isCompoundMonthly ? 12 : 1;

      // Compound Interest Formula: A = P(1 + r/n)^(nt)
      double maturityValue = principal * pow((1 + interestRate / compoundFrequency), (compoundFrequency * (period / 12)));
      double totalInterestEarned = maturityValue - principal;

      setState(() {
        maturityAmount = maturityValue;
        totalInterest = totalInterestEarned;
        showResults = true;
      });
    }
  }

  Future<void> _reset() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    bool confirmReset = await _showResetConfirmationDialog();
    if (confirmReset) {
      principalController.clear();
      interestController.clear();
      periodController.clear();
      setState(() {
        showResults = false;
        maturityAmount = 0;
        totalInterest = 0;
      });
    }
  }

  Future<bool> _showResetConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.confirm_reset ?? 'Confirm Reset'),
        content: Text(AppLocalizations.of(context)?.reset_confirmation ?? 'Are you sure you want to reset?'),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.fd_calculator ?? 'FD Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildInputField(AppLocalizations.of(context)?.principal_amount ?? 'Principal Amount', principalController, AppLocalizations.of(context)?.enter_principal ?? 'Enter principal amount'),
                _buildInputField(AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %', interestController, AppLocalizations.of(context)?.enter_interest ?? 'Enter interest rate'),
                _buildPeriodField(),
                SizedBox(height: Get.height * 0.02),
                _buildCompoundingFrequencyToggle(),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateFD, Colors.blue)),
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

  Widget _buildCompoundingFrequencyToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => isCompoundMonthly = true),
          child: Text(
            AppLocalizations.of(context)?.monthly ?? 'Monthly',
            style: TextStyle(
              color: isCompoundMonthly ? Colors.blue : null,
              fontSize: Get.textScaleFactor * 14, // Responsive text size
            ),
          ),
        ),
        Text(' | '),
        GestureDetector(
          onTap: () => setState(() => isCompoundMonthly = false),
          child: Text(
            AppLocalizations.of(context)?.annually ?? 'Annually',
            style: TextStyle(
              color: !isCompoundMonthly ? Colors.blue : null,
              fontSize: Get.textScaleFactor * 14, // Responsive text size
            ),
          ),
        ),
      ],
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
        _buildTableRow(AppLocalizations.of(context)?.maturity_amount ?? 'Maturity Amount', currencyFormatter.format(maturityAmount)),
        _buildTableRow(AppLocalizations.of(context)?.total_interest ?? 'Total Interest', currencyFormatter.format(totalInterest)),
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
