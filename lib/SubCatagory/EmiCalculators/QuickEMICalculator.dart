import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pie_chart/pie_chart.dart';

class QuickCalculator extends StatefulWidget {
  @override
  _QuickCalculatorState createState() => _QuickCalculatorState();
}

class _QuickCalculatorState extends State<QuickCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController loanAmountController = TextEditingController(text: '2150000');
  TextEditingController interestRateController = TextEditingController(text: '11.00');
  TextEditingController loanPeriodController = TextEditingController(text: '38');

  bool showResults = false;
  double emi = 0;
  double totalInterest = 0;
  double totalPayment = 0;

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  void calculateEMI() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      double loanAmount = double.parse(loanAmountController.text.replaceAll(',', ''));
      double interestRate = double.parse(interestRateController.text) / 12 / 100;
      int loanPeriod = int.parse(loanPeriodController.text) * 12;

      emi = (loanAmount * interestRate * pow((1 + interestRate), loanPeriod)) /
          (pow((1 + interestRate), loanPeriod) - 1);
      totalPayment = emi * loanPeriod;
      totalInterest = totalPayment - loanAmount;

      setState(() {
        showResults = true;
      });
    }
  }

  void reset() {
    FocusScope.of(context).unfocus();
    loanAmountController.clear();
    interestRateController.clear();
    loanPeriodController.clear();
    setState(() {
      showResults = false;
      emi = 0;
      totalInterest = 0;
      totalPayment = 0;
    });
  }

  String formatCurrency(double amount) {
    return currencyFormatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      AppLocalizations.of(context)?.loan_amount ?? 'Loan Amount': double.tryParse(loanAmountController.text) ?? 0,
      AppLocalizations.of(context)?.total_interest ?? 'Total Interest': totalInterest,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.quick_calculator ?? 'Quick Calculator'),
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
                  loanAmountController,
                  AppLocalizations.of(context)?.enter_amount ?? 'Enter loan amount',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.interest_rate ?? 'Interest Rate %',
                  interestRateController,
                  AppLocalizations.of(context)?.enter_interest ?? 'Enter interest rate',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.loan_period ?? 'Loan Period (Years)',
                  loanPeriodController,
                  AppLocalizations.of(context)?.enter_period ?? 'Enter loan period',
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: calculateEMI,
                        child: Text(AppLocalizations.of(context)?.calculate ?? 'Calculate'),
                      ),
                    ),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: reset,
                        child: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
                if (showResults) _buildResultsTable(),
                SizedBox(height: Get.height * 0.02),
                if (showResults)
                  PieChart(
                    dataMap: dataMap,
                    chartRadius: MediaQuery.of(context).size.width / 3,
                    colorList: [Colors.blueAccent, Colors.orange],
                    chartValuesOptions: ChartValuesOptions(showChartValuesInPercentage: true),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.height * 0.02),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)?.enter_value ?? 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResultsTable() {
    return Table(
      border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
      children: [
        _buildTableRow(AppLocalizations.of(context)?.monthly_emi ?? 'Monthly EMI', formatCurrency(emi)),
        _buildTableRow(AppLocalizations.of(context)?.total_interest ?? 'Total Interest', formatCurrency(totalInterest)),
        _buildTableRow(AppLocalizations.of(context)?.total_payment ?? 'Total Payment', formatCurrency(totalPayment)),
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
