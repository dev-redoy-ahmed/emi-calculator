import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdvancedEMICalculator extends StatefulWidget {
  @override
  _AdvancedEMICalculatorState createState() => _AdvancedEMICalculatorState();
}

class _AdvancedEMICalculatorState extends State<AdvancedEMICalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController processingFeeController = TextEditingController();
  TextEditingController prepaymentController = TextEditingController();
  TextEditingController interestChangeController = TextEditingController();

  bool isYears = true;
  bool showResults = false;
  double monthlyEMI = 0;
  double totalInterest = 0;
  double processingFees = 0;
  double totalPayment = 0;
  double prepaymentAmount = 0;
  double interestRateChange = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  // Method to format numbers with commas
  String _formatNumberWithCommas(String value) {
    if (value.isEmpty) return '';
    final parts = value.split('.');
    final integerPart = parts[0].replaceAll(',', '');  // Remove existing commas
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

      // Calculate EMI
      double emi = (amount * interest * pow((1 + interest), period)) / (pow((1 + interest), period) - 1);
      double totalAmount = emi * period;
      double totalInterestAmount = totalAmount - amount;

      // Calculate Processing Fees
      double processingFeesAmount = processingFeeController.text.isNotEmpty
          ? amount * double.parse(processingFeeController.text) / 100
          : 0;

      // Handle Prepayment
      double prepayment = prepaymentController.text.isNotEmpty
          ? double.parse(prepaymentController.text)
          : 0;

      // Handle Interest Rate Change
      double interestChange = interestChangeController.text.isNotEmpty
          ? double.parse(interestChangeController.text) / 100
          : 0;

      // Adjust amount based on prepayment
      if (prepayment > 0) {
        amount -= prepayment;
        totalAmount = (amount * interest * pow((1 + interest), period)) / (pow((1 + interest), period) - 1) * period;
        totalInterestAmount = totalAmount - amount;
      }

      // Adjust interest rate based on rate change
      if (interestChange > 0) {
        interest = (interest + interestChange) / 12;
        emi = (amount * interest * pow((1 + interest), period)) / (pow((1 + interest), period) - 1);
        totalAmount = emi * period;
        totalInterestAmount = totalAmount - amount;
      }

      setState(() {
        monthlyEMI = emi;
        totalInterest = totalInterestAmount;
        processingFees = processingFeesAmount;
        totalPayment = totalAmount + processingFeesAmount;
        prepaymentAmount = prepayment;
        interestRateChange = interestChange;
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
    prepaymentController.clear();
    interestChangeController.clear();
    setState(() {
      showResults = false;
      monthlyEMI = 0;
      totalInterest = 0;
      processingFees = 0;
      totalPayment = 0;
      prepaymentAmount = 0;
      interestRateChange = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.emi_calculator ?? 'EMI Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildInputField(AppLocalizations.of(context)?.loan_amount ?? 'Loan Amount', amountController, '\$10,000'), // Example for currency hint
                _buildInputField(AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %', interestController, '10%'),
                _buildPeriodField(),
                _buildInputField(AppLocalizations.of(context)?.processing_fee ?? 'Processing Fee %', processingFeeController, '3%', isOptional: true),
                _buildInputField(AppLocalizations.of(context)?.prepayment_amount ?? 'Prepayment Amount', prepaymentController, AppLocalizations.of(context)?.enter_prepayment_amount ?? 'Enter prepayment amount', isOptional: true),
                _buildInputField(AppLocalizations.of(context)?.interest_rate_change ?? 'Interest Rate Change (%)', interestChangeController, AppLocalizations.of(context)?.enter_interest_rate_change ?? 'Enter rate change (optional)', isOptional: true),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateEMI, Colors.blue)),
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
                  hintText: isYears ? AppLocalizations.of(context)?.years_hint ?? '1 year' : AppLocalizations.of(context)?.months_hint ?? '12 months', // Example formatted hint
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
    return Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        _buildTableRow(
            AppLocalizations.of(context)?.monthly_emi ?? 'Monthly EMI',
            '${currencyFormatter.format(monthlyEMI)}'
        ),
        _buildTableRow(
            AppLocalizations.of(context)?.total_interest ?? 'Total Interest',
            '${currencyFormatter.format(totalInterest)}'
        ),
        _buildTableRow(
            AppLocalizations.of(context)?.processing_fees ?? 'Processing Fees',
            '${currencyFormatter.format(processingFees)}'
        ),
        _buildTableRow(
            AppLocalizations.of(context)?.total_payment ?? 'Total Payment',
            '${currencyFormatter.format(totalPayment)}'
        ),
        _buildTableRow(AppLocalizations.of(context)?.prepayment_amount ?? 'Prepayment Amount', '${currencyFormatter.format(prepaymentAmount)}'),
        _buildTableRow(AppLocalizations.of(context)?.interest_rate_change ?? 'Interest Rate Change (%)', interestRateChange.toStringAsFixed(2)),
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
