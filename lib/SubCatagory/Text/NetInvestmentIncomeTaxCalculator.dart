import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class NetInvestmentIncomeTaxCalculator extends StatefulWidget {
  @override
  _NetInvestmentIncomeTaxCalculatorState createState() => _NetInvestmentIncomeTaxCalculatorState();
}

class _NetInvestmentIncomeTaxCalculatorState extends State<NetInvestmentIncomeTaxCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController investmentIncomeController = TextEditingController();
  TextEditingController deductionsController = TextEditingController();
  TextEditingController taxRateController = TextEditingController();

  bool showResults = false;
  double netInvestmentIncome = 0;
  double totalTax = 0;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // CurrencyController for dynamic currency
  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();

  void _calculateNetInvestmentTax() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double investmentIncome = double.parse(investmentIncomeController.text.replaceAll(',', ''));
      double deductions = double.parse(deductionsController.text.replaceAll(',', ''));
      double taxRate = double.parse(taxRateController.text) / 100;

      // Calculate net investment income and tax
      double netIncome = investmentIncome - deductions;
      double tax = netIncome * taxRate;

      setState(() {
        netInvestmentIncome = netIncome;
        totalTax = tax;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    investmentIncomeController.clear();
    deductionsController.clear();
    taxRateController.clear();

    setState(() {
      showResults = false;
      netInvestmentIncome = 0;
      totalTax = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.net_investment_income_tax_calculator ?? 'Net Investment Income Tax Calculator'),
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
                  AppLocalizations.of(context)?.investment_income ?? 'Investment Income',
                  investmentIncomeController,
                  '${currencyController.selectedCurrency.value} 1,00,000',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.deductions ?? 'Deductions',
                  deductionsController,
                  '${currencyController.selectedCurrency.value} 10,000',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.tax_note ?? 'Tax Rate (%)',
                  taxRateController,
                  '15%',
                ),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateNetInvestmentTax, Colors.blue)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.reset ?? 'Reset', _reset, Colors.grey)),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
                if (showResults) _buildResults(),
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

  Widget _buildResults() {
    return Obx(() => Container(
      margin: EdgeInsets.only(top: Get.height * 0.02),
      padding: EdgeInsets.all(Get.width * 0.04),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)?.net_investment_income_calculation ?? 'Net Investment Income Calculation:',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: Get.height * 0.01),
          _buildResultItem(
            AppLocalizations.of(context)?.net_investment_income ?? 'Net Investment Income:',
            currencyFormatter.format(netInvestmentIncome),
          ),
          SizedBox(height: Get.height * 0.01),
          _buildResultItem(
            AppLocalizations.of(context)?.tax_owed ?? 'Tax Owed:',
            currencyFormatter.format(totalTax),
            Colors.red,
          ),
        ],
      ),
    ));
  }

  Widget _buildResultItem(String label, String value, [Color? textColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: Get.textScaleFactor * 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: Get.textScaleFactor * 14,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
