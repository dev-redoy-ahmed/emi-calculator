import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class BusinessLoanEMICalculator extends StatefulWidget {
  @override
  _BusinessLoanEMICalculatorState createState() => _BusinessLoanEMICalculatorState();
}

class _BusinessLoanEMICalculatorState extends State<BusinessLoanEMICalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController loanAmountController = TextEditingController();
  TextEditingController interestRateController = TextEditingController();
  TextEditingController tenureController = TextEditingController();

  final RxBool isYears = true.obs;
  final RxBool showResults = false.obs;

  final RxDouble monthlyEMI = 0.0.obs;
  final RxDouble totalInterest = 0.0.obs;
  final RxDouble totalPayment = 0.0.obs;

  final CurrencyController currencyController = Get.find<CurrencyController>();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  String _formatNumberWithCommas(String value) {
    if (value == '') return '';
    final parts = value.split('.');
    final integerPart = parts[0].replaceAll(',', '');
    final formattedIntegerPart = NumberFormat('#,##0').format(int.parse(integerPart));

    if (parts.length > 1) {
      return '$formattedIntegerPart.${parts[1]}';
    } else {
      return formattedIntegerPart;
    }
  }

  void _calculateEMI() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      double loanAmount = double.parse(loanAmountController.text.replaceAll(',', ''));
      double interestRate = double.parse(interestRateController.text) / 12 / 100;
      int tenure = int.parse(tenureController.text);
      if (isYears.value) tenure *= 12;

      double emi = (loanAmount * interestRate * pow((1 + interestRate), tenure)) /
          (pow((1 + interestRate), tenure) - 1);

      double totalAmount = emi * tenure;
      double totalInterestAmount = totalAmount - loanAmount;

      monthlyEMI.value = emi;
      totalInterest.value = totalInterestAmount;
      totalPayment.value = totalAmount;
      showResults.value = true;
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    loanAmountController.clear();
    interestRateController.clear();
    tenureController.clear();

    showResults.value = false;
    monthlyEMI.value = 0;
    totalInterest.value = 0;
    totalPayment.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localize.emi_calculator),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Obx(() => Text(
                '(${currencyController.selectedCurrencyName.value})',
                style: TextStyle(fontSize: 18),
              )),
            ),
          ),
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
                _buildInputField(localize.loan_amount, loanAmountController, '${currencyController.selectedCurrency.value} 100,000'),
                _buildInputField(localize.interest_rate, interestRateController, '10%'),
                _buildPeriodField(localize),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(localize.calculate, _calculateEMI, Colors.blue)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(localize.reset, _reset, Colors.grey)),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
                Obx(() => showResults.value ? _buildResultsTable(localize) : SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Container(
      margin: EdgeInsets.only(bottom: Get.height * 0.01),
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.30,
            child: Text(label),
          ),
          Expanded(
            child: Container(
              height: 40,
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
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enter_value;
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

  Widget _buildPeriodField(AppLocalizations localize) {
    return Container(
      margin: EdgeInsets.only(bottom: Get.height * 0.01),
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.30,
            child: Text(localize.loan_period),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: TextFormField(
                controller: tenureController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: localize.enter_period,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enter_value;
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(width: Get.width * 0.02),
          Obx(() => GestureDetector(
            onTap: () => isYears.value = true,
            child: Text(
              localize.years,
              style: TextStyle(
                color: isYears.value ? Colors.blue : null,
                fontSize: Get.textScaleFactor * 14,
              ),
            ),
          )),
          Text(' | '),
          Obx(() => GestureDetector(
            onTap: () => isYears.value = false,
            child: Text(
              localize.months,
              style: TextStyle(
                color: !isYears.value ? Colors.blue : null,
                fontSize: Get.textScaleFactor * 14,
              ),
            ),
          )),
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

  Widget _buildResultsTable(AppLocalizations localize) {
    return Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        _buildTableRow(localize.monthly_emi, '${currencyController.selectedCurrency.value} ${numberFormatter.format(monthlyEMI.value)}'),
        _buildTableRow(localize.total_interest, '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalInterest.value)}'),
        _buildTableRow(localize.total_payment, '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalPayment.value)}'),
      ],
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