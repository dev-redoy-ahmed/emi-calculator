import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class LoanComparisonCalculator extends StatefulWidget {
  @override
  _LoanComparisonCalculatorState createState() => _LoanComparisonCalculatorState();
}

class _LoanComparisonCalculatorState extends State<LoanComparisonCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amount1Controller = TextEditingController();
  TextEditingController interest1Controller = TextEditingController();
  TextEditingController period1Controller = TextEditingController();

  TextEditingController amount2Controller = TextEditingController();
  TextEditingController interest2Controller = TextEditingController();
  TextEditingController period2Controller = TextEditingController();

  final RxBool isYears1 = true.obs;
  final RxBool isYears2 = true.obs;
  final RxBool showResults = false.obs;

  final RxDouble monthlyEMI1 = 0.0.obs;
  final RxDouble totalInterest1 = 0.0.obs;
  final RxDouble totalPayment1 = 0.0.obs;

  final RxDouble monthlyEMI2 = 0.0.obs;
  final RxDouble totalInterest2 = 0.0.obs;
  final RxDouble totalPayment2 = 0.0.obs;

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

  void _calculateComparison() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _calculateLoan(amount1Controller, interest1Controller, period1Controller, isYears1.value,
            (emi, totalInterest, totalPayment) {
          monthlyEMI1.value = emi;
          totalInterest1.value = totalInterest;
          totalPayment1.value = totalPayment;
        },
      );

      _calculateLoan(amount2Controller, interest2Controller, period2Controller, isYears2.value,
            (emi, totalInterest, totalPayment) {
          monthlyEMI2.value = emi;
          totalInterest2.value = totalInterest;
          totalPayment2.value = totalPayment;
        },
      );

      showResults.value = true;
    }
  }

  void _calculateLoan(
      TextEditingController amountController,
      TextEditingController interestController,
      TextEditingController periodController,
      bool isYears,
      Function(double, double, double) callback,
      ) {
    double amount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
    double interest = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
    int period = int.tryParse(periodController.text) ?? 0;
    if (isYears) period *= 12;

    if (amount > 0 && interest > 0 && period > 0) {
      double emi = (amount * interest * pow((1 + interest), period)) / (pow((1 + interest), period) - 1);
      double totalAmount = emi * period;
      double totalInterestAmount = totalAmount - amount;

      callback(emi, totalInterestAmount, totalAmount);
    } else {
      callback(0, 0, 0);
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    amount1Controller.clear();
    interest1Controller.clear();
    period1Controller.clear();
    amount2Controller.clear();
    interest2Controller.clear();
    period2Controller.clear();
    showResults.value = false;
    isYears1.value = true;
    isYears2.value = true;
    monthlyEMI1.value = 0;
    totalInterest1.value = 0;
    totalPayment1.value = 0;
    monthlyEMI2.value = 0;
    totalInterest2.value = 0;
    totalPayment2.value = 0;
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLoanInputs('LOAN 1', amount1Controller, interest1Controller, period1Controller, isYears1, localize)),
                    SizedBox(width: 16),
                    Expanded(child: _buildLoanInputs('LOAN 2', amount2Controller, interest2Controller, period2Controller, isYears2, localize)),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildButton(localize.calculate, _calculateComparison, Colors.blue)),
                    SizedBox(width: 16),
                    Expanded(child: _buildButton(localize.reset, _reset, Colors.grey)),
                  ],
                ),
                SizedBox(height: 16),
                Obx(() => showResults.value ? _buildComparisonTable(localize) : SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanInputs(String title, TextEditingController amountController, TextEditingController interestController, TextEditingController periodController, RxBool isYears, AppLocalizations localize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        SizedBox(height: 8),
        _buildInputField(localize.loan_amount, amountController, '${currencyController.selectedCurrency.value} 100,000'),
        SizedBox(height: 8),
        _buildInputField(localize.interest_rate, interestController, '10%'),
        SizedBox(height: 8),
        _buildPeriodField(periodController, isYears, localize),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Container(
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
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.enter_value;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPeriodField(TextEditingController controller, RxBool isYears, AppLocalizations localize) {
    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: localize.loan_period,
                hintText: localize.enter_period,
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enter_value;
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 8),
          Obx(() => GestureDetector(
            onTap: () => isYears.value = true,
            child: Text(localize.years, style: TextStyle(color: isYears.value ? Colors.blue : Colors.grey, fontSize: 12)),
          )),
          Text(' | ', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Obx(() => GestureDetector(
            onTap: () => isYears.value = false,
            child: Text(localize.months, style: TextStyle(color: !isYears.value ? Colors.blue : Colors.grey, fontSize: 12)),
          )),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        child: Text(label, style: TextStyle(fontSize: 14)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  Widget _buildComparisonTable(AppLocalizations localize) {
    return Obx(() => Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('Loan 1', isHeader: true),
            _buildTableCell('Loan 2', isHeader: true),
          ],
        ),
        _buildComparisonRow(localize.monthly_emi, monthlyEMI1.value, monthlyEMI2.value),
        _buildComparisonRow(localize.total_interest, totalInterest1.value, totalInterest2.value),
        _buildComparisonRow(localize.total_payment, totalPayment1.value, totalPayment2.value),
      ],
    ));
  }

  TableRow _buildComparisonRow(String label, double value1, double value2) {
    Color? textColor1 = value1 < value2 ? Colors.green : (value1 > value2 ? Colors.red : null);
    Color? textColor2 = value2 < value1 ? Colors.green : (value2 > value1 ? Colors.red : null);

    return TableRow(
      children: [
        _buildTableCell(label),
        _buildTableCell('${currencyController.selectedCurrency.value} ${numberFormatter.format(value1)}', textColor: textColor1),
        _buildTableCell('${currencyController.selectedCurrency.value} ${numberFormatter.format(value2)}', textColor: textColor2),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? textColor}) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.right,
      ),
    );
  }
}