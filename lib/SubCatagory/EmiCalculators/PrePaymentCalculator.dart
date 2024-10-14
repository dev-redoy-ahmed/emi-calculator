import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrePaymentCalculator extends StatefulWidget {
  @override
  _PrePaymentCalculatorState createState() => _PrePaymentCalculatorState();
}

class _PrePaymentCalculatorState extends State<PrePaymentCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController prepaymentAmountController = TextEditingController();
  TextEditingController prepaymentMonthController = TextEditingController();

  bool isYears = true;
  bool showResults = false;
  double originalMonthlyEMI = 0;
  double revisedMonthlyEMI = 0;
  int originalTenure = 0;
  int revisedTenure = 0;
  double totalInterestOriginal = 0;
  double totalInterestRevised = 0;
  double totalPaymentOriginal = 0;
  double totalPaymentRevised = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void _calculateEMI() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));
      double interest = double.parse(interestController.text) / 12 / 100;
      originalTenure = int.parse(periodController.text);
      if (isYears) originalTenure *= 12;
      double prepaymentAmount = double.parse(prepaymentAmountController.text.replaceAll(',', ''));
      int prepaymentMonth = int.parse(prepaymentMonthController.text);

      // Calculate original EMI
      originalMonthlyEMI = (amount * interest * pow((1 + interest), originalTenure)) / (pow((1 + interest), originalTenure) - 1);
      totalInterestOriginal = (originalMonthlyEMI * originalTenure) - amount;
      totalPaymentOriginal = originalMonthlyEMI * originalTenure;

      // Calculate revised loan details after prepayment
      double outstandingBalance = amount;
      for (int i = 1; i <= originalTenure; i++) {
        double interestComponent = outstandingBalance * interest;
        double principalComponent = originalMonthlyEMI - interestComponent;
        outstandingBalance -= principalComponent;

        if (i == prepaymentMonth) {
          outstandingBalance -= prepaymentAmount;
          if (outstandingBalance <= 0) {
            revisedTenure = i;
            break;
          }
        }
      }

      if (revisedTenure == 0) {
        // Recalculate EMI for the remaining balance and period
        int remainingPeriod = originalTenure - prepaymentMonth + 1;
        revisedMonthlyEMI = (outstandingBalance * interest * pow((1 + interest), remainingPeriod)) / (pow((1 + interest), remainingPeriod) - 1);
        revisedTenure = originalTenure;
      }

      // Calculate revised total interest and payment
      totalInterestRevised = (revisedMonthlyEMI * (revisedTenure - prepaymentMonth + 1)) +
          (originalMonthlyEMI * (prepaymentMonth - 1)) -
          amount + prepaymentAmount;
      totalPaymentRevised = (revisedMonthlyEMI * (revisedTenure - prepaymentMonth + 1)) +
          (originalMonthlyEMI * (prepaymentMonth - 1)) +
          prepaymentAmount;

      setState(() {
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    amountController.clear();
    interestController.clear();
    periodController.clear();
    prepaymentAmountController.clear();
    prepaymentMonthController.clear();
    setState(() {
      showResults = false;
      originalMonthlyEMI = 0;
      revisedMonthlyEMI = 0;
      originalTenure = 0;
      revisedTenure = 0;
      totalInterestOriginal = 0;
      totalInterestRevised = 0;
      totalPaymentOriginal = 0;
      totalPaymentRevised = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.prepayment_calculator ?? 'Prepayment Calculator'),
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
                    AppLocalizations.of(context)?.enter_amount ?? 'Enter loan amount'
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %',
                    interestController,
                    AppLocalizations.of(context)?.enter_interest ?? 'Enter interest rate'
                ),
                _buildPeriodField(),
                _buildInputField(
                    AppLocalizations.of(context)?.prepayment_amount ?? 'Prepayment Amount',
                    prepaymentAmountController,
                    AppLocalizations.of(context)?.enter_prepayment_amount ?? 'Enter prepayment amount'
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.prepayment_month ?? 'Prepayment Month',
                    prepaymentMonthController,
                    AppLocalizations.of(context)?.enter_prepayment_month ?? 'Enter prepayment month'
                ),
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

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
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
                  if (value == null || value.isEmpty) {
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
    return Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        _buildTableRow(AppLocalizations.of(context)?.original_monthly_emi ?? 'Original Monthly EMI', currencyFormatter.format(originalMonthlyEMI)),
        _buildTableRow(AppLocalizations.of(context)?.revised_monthly_emi ?? 'Revised Monthly EMI', currencyFormatter.format(revisedMonthlyEMI)),
        _buildTableRow(AppLocalizations.of(context)?.original_tenure ?? 'Original Tenure', '${isYears ? originalTenure ~/ 12 : originalTenure} ${isYears ? 'years' : 'months'}'),
        _buildTableRow(AppLocalizations.of(context)?.revised_tenure ?? 'Revised Tenure', '${isYears ? revisedTenure ~/ 12 : revisedTenure} ${isYears ? 'years' : 'months'}'),
        _buildTableRow(AppLocalizations.of(context)?.total_interest_original ?? 'Total Interest (Original)', currencyFormatter.format(totalInterestOriginal)),
        _buildTableRow(AppLocalizations.of(context)?.total_interest_revised ?? 'Total Interest (Revised)', currencyFormatter.format(totalInterestRevised)),
        _buildTableRow(AppLocalizations.of(context)?.total_payment_original ?? 'Total Payment (Original)', currencyFormatter.format(totalPaymentOriginal)),
        _buildTableRow(AppLocalizations.of(context)?.total_payment_revised ?? 'Total Payment (Revised)', currencyFormatter.format(totalPaymentRevised)),
        _buildTableRow(AppLocalizations.of(context)?.interest_saved ?? 'Interest Saved', currencyFormatter.format(totalInterestOriginal - totalInterestRevised)),
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
