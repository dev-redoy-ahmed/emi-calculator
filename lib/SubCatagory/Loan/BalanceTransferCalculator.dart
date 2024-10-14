import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class BalanceTransferCalculator extends StatefulWidget {
  @override
  _BalanceTransferCalculatorState createState() => _BalanceTransferCalculatorState();
}

class _BalanceTransferCalculatorState extends State<BalanceTransferCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController outstandingAmountController = TextEditingController();
  TextEditingController oldInterestRateController = TextEditingController();
  TextEditingController newInterestRateController = TextEditingController();
  TextEditingController remainingTenureController = TextEditingController();

  final RxBool isYears = true.obs;
  final RxBool showResults = false.obs;

  final RxDouble oldEMI = 0.0.obs;
  final RxDouble newEMI = 0.0.obs;
  final RxDouble totalSavings = 0.0.obs;

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

  void _calculateBalanceTransfer() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      double outstandingAmount = double.parse(outstandingAmountController.text.replaceAll(',', ''));
      double oldInterestRate = double.parse(oldInterestRateController.text) / 12 / 100;
      double newInterestRate = double.parse(newInterestRateController.text) / 12 / 100;
      int remainingTenure = int.parse(remainingTenureController.text);
      if (isYears.value) remainingTenure *= 12;

      double oldEmi = (outstandingAmount * oldInterestRate * pow((1 + oldInterestRate), remainingTenure)) /
          (pow((1 + oldInterestRate), remainingTenure) - 1);

      double newEmi = (outstandingAmount * newInterestRate * pow((1 + newInterestRate), remainingTenure)) /
          (pow((1 + newInterestRate), remainingTenure) - 1);

      double totalOldPayment = oldEmi * remainingTenure;
      double totalNewPayment = newEmi * remainingTenure;
      double savings = totalOldPayment - totalNewPayment;

      oldEMI.value = oldEmi;
      newEMI.value = newEmi;
      totalSavings.value = savings;
      showResults.value = true;
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    outstandingAmountController.clear();
    oldInterestRateController.clear();
    newInterestRateController.clear();
    remainingTenureController.clear();

    showResults.value = false;
    oldEMI.value = 0;
    newEMI.value = 0;
    totalSavings.value = 0;
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
                _buildInputField(localize.loan_amount, outstandingAmountController, '${currencyController.selectedCurrency.value} 100,000'),
                _buildInputField(localize.original_interest_rate, oldInterestRateController, '10%'),
                _buildInputField(localize.new_interest_rate, newInterestRateController, '8%'),
                _buildPeriodField(localize),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(localize.calculate, _calculateBalanceTransfer, Colors.blue)),
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
                controller: remainingTenureController,
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
        _buildTableRow(localize.original_emi, '${currencyController.selectedCurrency.value} ${numberFormatter.format(oldEMI.value)}'),
        _buildTableRow(localize.new_emi, '${currencyController.selectedCurrency.value} ${numberFormatter.format(newEMI.value)}'),
        _buildTableRow(localize.interest_saved, '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalSavings.value)}'),
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