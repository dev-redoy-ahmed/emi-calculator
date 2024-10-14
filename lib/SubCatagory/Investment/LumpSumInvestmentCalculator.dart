import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class LumpSumInvestmentCalculator extends StatefulWidget {
  @override
  _LumpSumInvestmentCalculatorState createState() => _LumpSumInvestmentCalculatorState();
}

class _LumpSumInvestmentCalculatorState extends State<LumpSumInvestmentCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  final RxBool showResults = false.obs;
  final RxDouble maturityAmount = 0.0.obs;
  final RxDouble totalInterest = 0.0.obs;

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

  void _calculateLumpSum() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      double principal = double.parse(amountController.text.replaceAll(',', ''));
      double rateOfInterest = double.parse(interestController.text) / 100;
      int period = int.parse(periodController.text);

      double maturity = principal * pow((1 + rateOfInterest), period);
      double interestEarned = maturity - principal;

      maturityAmount.value = maturity;
      totalInterest.value = interestEarned;
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
    totalInterest.value = 0;
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
                    localize.loan_amount, // Using "Loan Amount" for "Initial Investment"
                    amountController,
                    '${currencyController.selectedCurrency.value} 10,000'
                ),
                _buildInputField(
                    localize.interest_rate,
                    interestController,
                    '10%'
                ),
                _buildInputField(
                    localize.loan_period,
                    periodController,
                    localize.years_hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(localize.calculate, _calculateLumpSum, Colors.blue)),
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
        _buildTableRow(localize.total_interest, '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalInterest.value)}'),
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