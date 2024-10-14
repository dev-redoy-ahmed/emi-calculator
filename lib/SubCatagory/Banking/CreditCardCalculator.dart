import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class CreditCardCalculator extends StatefulWidget {
  @override
  _CreditCardCalculatorState createState() => _CreditCardCalculatorState();
}

class _CreditCardCalculatorState extends State<CreditCardCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController balanceController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController paymentController = TextEditingController();

  bool showResults = false;
  double totalInterestPaid = 0;
  double totalAmountPaid = 0;
  int monthsToPayOff = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Currency Controller
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateCreditCard() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double balance = double.parse(balanceController.text.replaceAll(',', ''));
      double annualInterest = double.parse(interestController.text) / 100;
      double monthlyInterest = annualInterest / 12;
      double monthlyPayment = double.parse(paymentController.text.replaceAll(',', ''));

      int months = 0;
      double totalPaid = 0;
      double totalInterest = 0;

      while (balance > 0) {
        double interestForMonth = balance * monthlyInterest;
        balance += interestForMonth;
        if (balance < monthlyPayment) {
          totalPaid += balance;
          totalInterest += interestForMonth;
          balance = 0;
        } else {
          balance -= monthlyPayment;
          totalPaid += monthlyPayment;
          totalInterest += interestForMonth;
        }
        months++;
      }

      setState(() {
        totalInterestPaid = totalInterest;
        totalAmountPaid = totalPaid;
        monthsToPayOff = months;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    balanceController.clear();
    interestController.clear();
    paymentController.clear();
    setState(() {
      showResults = false;
      totalInterestPaid = 0;
      totalAmountPaid = 0;
      monthsToPayOff = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.credit_card_calculator ?? 'Credit Card Calculator'),
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
                _buildInputField(AppLocalizations.of(context)?.outstanding_balance ?? 'Outstanding Balance', balanceController, '\$10,000'),
                _buildInputField(AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %', interestController, '18%'),
                _buildInputField(AppLocalizations.of(context)?.monthly_payment ?? 'Monthly Payment', paymentController, '\$500'),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateCreditCard, Colors.blue)),
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
        _buildTableRow(AppLocalizations.of(context)?.months_to_pay_off ?? 'Months to Pay Off', monthsToPayOff.toString()),
        _buildTableRow(AppLocalizations.of(context)?.total_amount_paid ?? 'Total Amount Paid', '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalAmountPaid)}'),
        _buildTableRow(AppLocalizations.of(context)?.total_interest_paid ?? 'Total Interest Paid', '${currencyController.selectedCurrency.value} ${numberFormatter.format(totalInterestPaid)}'),
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
