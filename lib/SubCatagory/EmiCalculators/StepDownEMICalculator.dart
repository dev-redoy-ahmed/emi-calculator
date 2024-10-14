import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StepDownEMICalculator extends StatefulWidget {
  @override
  _StepDownEMICalculatorState createState() => _StepDownEMICalculatorState();
}

class _StepDownEMICalculatorState extends State<StepDownEMICalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController stepDownRateController = TextEditingController();
  TextEditingController stepDownFrequencyController = TextEditingController();
  TextEditingController processingFeeController = TextEditingController();

  bool isYears = true;
  bool showResults = false;
  List<double> yearlyEMIs = [];
  double totalInterest = 0;
  double processingFees = 0;
  double totalPayment = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateEMI() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));
      double interest = double.parse(interestController.text) / 12 / 100;
      int period = int.parse(periodController.text);
      if (isYears) period *= 12;
      double stepDownRate = double.parse(stepDownRateController.text) / 100;
      int stepDownFrequency = int.parse(stepDownFrequencyController.text);

      yearlyEMIs.clear();
      double remainingAmount = amount;
      double totalInterestPaid = 0;

      // Initial EMI (highest EMI at the start of the loan)
      double initialEMI = (amount * interest * pow(1 + interest, period)) / (pow(1 + interest, period) - 1);

      for (int year = 0; year < (period / 12).ceil(); year++) {
        int monthsInYear = (year == (period / 12).floor()) ? period % 12 : 12;
        num stepDownFactor = pow(1 - stepDownRate, year ~/ stepDownFrequency);

        double emi = initialEMI * stepDownFactor;
        yearlyEMIs.add(emi);

        for (int month = 0; month < monthsInYear; month++) {
          double interestPaid = remainingAmount * interest;
          double principalPaid = emi - interestPaid;

          if (principalPaid > remainingAmount) {
            principalPaid = remainingAmount;
            emi = principalPaid + interestPaid;
          }

          totalInterestPaid += interestPaid;
          remainingAmount -= principalPaid;

          if (remainingAmount <= 0) break;
        }

        if (remainingAmount <= 0) break;
      }

      double processingFeesAmount = processingFeeController.text.isNotEmpty
          ? amount * double.parse(processingFeeController.text) / 100
          : 0;

      setState(() {
        totalInterest = totalInterestPaid;
        processingFees = processingFeesAmount;
        totalPayment = amount + totalInterestPaid + processingFeesAmount;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    amountController.clear();
    interestController.clear();
    periodController.clear();
    stepDownRateController.clear();
    stepDownFrequencyController.clear();
    processingFeeController.clear();
    setState(() {
      showResults = false;
      yearlyEMIs.clear();
      totalInterest = 0;
      processingFees = 0;
      totalPayment = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.step_down_emi_calculator ?? 'Step-down EMI Calculator'),
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
                  AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %',
                  interestController,
                  AppLocalizations.of(context)?.enter_interest ?? 'Enter interest rate',
                ),
                _buildPeriodField(),
                _buildInputField(
                  AppLocalizations.of(context)?.step_down_rate ?? 'Step-down Rate %',
                  stepDownRateController,
                  AppLocalizations.of(context)?.enter_step_down_rate ?? 'Enter step-down rate',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.step_down_frequency ?? 'Step-down Frequency (Years)',
                  stepDownFrequencyController,
                  AppLocalizations.of(context)?.enter_step_down_frequency ?? 'Enter step-down frequency',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.processing_fee ?? 'Processing Fee %',
                  processingFeeController,
                  AppLocalizations.of(context)?.processing_fee ?? 'Ex: 3%',
                  isOptional: true,
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        AppLocalizations.of(context)?.calculate ?? 'Calculate',
                        _calculateEMI,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(
                      child: _buildButton(
                        AppLocalizations.of(context)?.reset ?? 'Reset',
                        _reset,
                        Colors.grey,
                      ),
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
      margin: EdgeInsets.only(bottom: Get.height * 0.01),
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.40,
            child: Text(label),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14),
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
            width: Get.width * 0.40,
            child: Text(AppLocalizations.of(context)?.loan_period ?? 'Loan Period'),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: TextFormField(
                controller: periodController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: AppLocalizations.of(context)?.enter_period ?? 'Enter loan period',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14),
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
                fontSize: Get.textScaleFactor * 14,
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
                fontSize: Get.textScaleFactor * 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        child: Text(
          label,
          style: TextStyle(fontSize: Get.textScaleFactor * 14),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    List<TableRow> rows = [
      _buildTableRow(AppLocalizations.of(context)?.total_interest ?? 'Total Interest', currencyFormatter.format(totalInterest)),
      _buildTableRow(AppLocalizations.of(context)?.processing_fees ?? 'Processing Fees', currencyFormatter.format(processingFees)),
      _buildTableRow(AppLocalizations.of(context)?.total_payment ?? 'Total Payment', currencyFormatter.format(totalPayment)),
    ];

    for (int i = 0; i < yearlyEMIs.length; i++) {
      rows.add(_buildTableRow('Year ${i + 1} EMI', currencyFormatter.format(yearlyEMIs[i])));
    }

    return Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: rows,
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(Get.width * 0.02),
          child: Text(label),
        ),
        Padding(
          padding: EdgeInsets.all(Get.width * 0.02),
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
