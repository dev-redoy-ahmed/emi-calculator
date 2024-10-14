import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class CAGRCalculator extends StatefulWidget {
  @override
  _CAGRCalculatorState createState() => _CAGRCalculatorState();
}

class _CAGRCalculatorState extends State<CAGRCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController initialInvestmentController = TextEditingController();
  TextEditingController finalValueController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  final RxBool showResults = false.obs;
  final RxDouble cagr = 0.0.obs;

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

  void _calculateCAGR() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      double initialInvestment = double.parse(initialInvestmentController.text.replaceAll(',', ''));
      double finalValue = double.parse(finalValueController.text.replaceAll(',', ''));
      int period = int.parse(periodController.text);

      double cagrValue = (pow((finalValue / initialInvestment), (1 / period)) - 1) * 100;

      cagr.value = cagrValue;
      showResults.value = true;
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    initialInvestmentController.clear();
    finalValueController.clear();
    periodController.clear();
    showResults.value = false;
    cagr.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('CAGR Calculator'), // We don't have a specific string for CAGR Calculator
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
                    initialInvestmentController,
                    '${currencyController.selectedCurrency.value} 10,000'
                ),
                _buildInputField(
                    localize.total_payment, // Using "Total Payment" for "Final Value"
                    finalValueController,
                    '${currencyController.selectedCurrency.value} 15,000'
                ),
                _buildInputField(
                    localize.loan_period, // Using "Loan Period" for "Investment Period"
                    periodController,
                    localize.years_hint
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(localize.calculate, _calculateCAGR, Colors.blue)),
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
        _buildTableRow(
            'CAGR (%)', // We don't have a specific string for CAGR
            '${numberFormatter.format(cagr.value)}%'
        ),
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