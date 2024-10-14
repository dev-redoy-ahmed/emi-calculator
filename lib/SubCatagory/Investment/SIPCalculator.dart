import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class SIPCalculator extends StatefulWidget {
  @override
  _SIPCalculatorState createState() => _SIPCalculatorState();
}

class _SIPCalculatorState extends State<SIPCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  final RxBool isYears = true.obs;
  final RxBool showResults = false.obs;
  final RxDouble maturityAmount = 0.0.obs;
  final RxDouble totalInvestment = 0.0.obs;
  final RxDouble totalInterestEarned = 0.0.obs;

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

  void _calculateSIP() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      double monthlyInvestment = double.parse(amountController.text.replaceAll(',', ''));
      double annualInterestRate = double.parse(interestController.text) / 100;
      int period = int.parse(periodController.text);
      if (isYears.value) period *= 12;

      double monthlyRate = annualInterestRate / 12;
      double maturity = monthlyInvestment *
          (pow(1 + monthlyRate, period) - 1) / monthlyRate *
          (1 + monthlyRate);
      double totalInvestmentAmount = monthlyInvestment * period;
      double totalInterestAmount = maturity - totalInvestmentAmount;

      maturityAmount.value = maturity;
      totalInvestment.value = totalInvestmentAmount;
      totalInterestEarned.value = totalInterestAmount;
      showResults.value = true;
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    amountController.clear();
    interestController.clear();
    periodController.clear();
    showResults.value = false;
    maturityAmount.value = 0;
    totalInvestment.value = 0;
    totalInterestEarned.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localize.quick_calculator),
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
                _buildInputField(
                    localize.monthly_emi, // Using "Monthly EMI" for "Monthly Investment"
                    amountController,
                    '${currencyController.selectedCurrency.value} 1,000'
                ),
                _buildInputField(
                    localize.interest_rate,
                    interestController,
                    '12%'
                ),
                _buildPeriodField(localize),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(localize.calculate, _calculateSIP, Colors.blue)),
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
                controller: periodController,
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
        _buildTableRow(localize.total_payment, '${currencyController.selectedCurrency.value} ${numberFormatter.format(maturityAmount.value)}'),
        _buildTableRow(localize.loan_amount, '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalInvestment.value)}'),
        _buildTableRow(localize.total_interest, '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalInterestEarned.value)}'),
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