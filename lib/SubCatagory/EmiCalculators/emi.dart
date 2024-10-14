import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';
import 'emiinfodetails.dart';

class EMICalculator extends StatefulWidget {
  @override
  _EMICalculatorState createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController processingFeeController = TextEditingController();

  bool isYears = true;
  bool showResults = false;
  double monthlyEMI = 0;
  double totalInterest = 0;
  double processingFees = 0;
  double totalPayment = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController

  // Use NumberFormat for comma-separated numbers and currency formatting
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  // Custom formatter for input
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

  void _calculateEMI() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));
      double interest = double.parse(interestController.text) / 12 / 100;
      int period = int.parse(periodController.text);
      if (isYears) period *= 12;

      double emi = (amount * interest * pow((1 + interest), period)) / (pow((1 + interest), period) - 1);
      double totalAmount = emi * period;
      double totalInterestAmount = totalAmount - amount;
      double processingFeesAmount = processingFeeController.text.isNotEmpty
          ? amount * double.parse(processingFeeController.text) / 100
          : 0;

      setState(() {
        monthlyEMI = emi;
        totalInterest = totalInterestAmount;
        processingFees = processingFeesAmount;
        totalPayment = totalAmount + processingFeesAmount;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    amountController.clear();
    interestController.clear();
    periodController.clear();
    processingFeeController.clear();
    setState(() {
      showResults = false;
      monthlyEMI = 0;
      totalInterest = 0;
      processingFees = 0;
      totalPayment = 0;
    });
  }

  void _showDetails() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (showResults) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EMIDetailsPage(
          amount: double.parse(amountController.text.replaceAll(',', '')),
          interest: double.parse(interestController.text),
          period: int.parse(periodController.text),
          isYears: isYears,
          monthlyEMI: monthlyEMI,
          totalInterest: totalInterest,
          processingFees: processingFees,
          totalPayment: totalPayment,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EMI Calculator'),
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
                    AppLocalizations.of(context)?.loan_amount ?? 'Loan Amount',
                    amountController,
                    '\$10,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %',
                    interestController,
                    '10%' // Example formatted hint
                ),
                _buildPeriodField(),
                _buildInputField(
                    AppLocalizations.of(context)?.processing_fee ?? 'Processing Fee %',
                    processingFeeController,
                    '3%', // Example formatted hint
                    isOptional: true
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateEMI, Colors.blue)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.reset ?? 'Reset', _reset, Colors.grey)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.details ?? 'Detail', _showDetails, Colors.blue)),
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
                  hintText: hint,  // Use formatted hint text
                  hintStyle: TextStyle(color: Colors.grey.shade500), // Light hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced vertical padding
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14), // Responsive text size
                validator: (value) {
                  if (!isOptional && (value == null || value.isEmpty)) {
                    return 'Please enter a value';
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
            child: Text(AppLocalizations.of(context)?.loan_period ?? 'Period'),
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
                  hintText: isYears ? '1 year' : '12 months', // Example formatted hint
                  hintStyle: TextStyle(color: Colors.grey.shade500), // Light hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced vertical padding
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14), // Responsive text size
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
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
                  fontSize: Get.textScaleFactor * 14), // Responsive text size
            ),
          ),
          Text(' | '),
          GestureDetector(
            onTap: () => setState(() => isYears = false),
            child: Text(
              AppLocalizations.of(context)?.months ?? 'Months',
              style: TextStyle(
                  color: !isYears ? Colors.blue : null,
                  fontSize: Get.textScaleFactor * 14), // Responsive text size
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
            AppLocalizations.of(context)?.monthly_emi ?? 'Monthly EMI',
            '${currencyController.selectedCurrency.value} ${numberFormatter.format(monthlyEMI)}'
        ),
        _buildTableRow(
            AppLocalizations.of(context)?.total_interest ?? 'Total Interest',
            '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalInterest)}'
        ),
        _buildTableRow(
            AppLocalizations.of(context)?.processing_fees ?? 'Processing Fees',
            '${currencyController.selectedCurrency.value} ${numberFormatter.format(processingFees)}'
        ),
        _buildTableRow(
            AppLocalizations.of(context)?.total_payment ?? 'Total Payment',
            '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalPayment)}'
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
