import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class IncomeTaxCalculator extends StatefulWidget {
  @override
  _IncomeTaxCalculatorState createState() => _IncomeTaxCalculatorState();
}

class _IncomeTaxCalculatorState extends State<IncomeTaxCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController incomeController = TextEditingController();
  TextEditingController deductionsController = TextEditingController();
  TextEditingController gstRateController = TextEditingController();

  bool showResults = false;
  double totalTax = 0;
  double taxableIncome = 0;
  double effectiveTaxRate = 0;
  double gstAmount = 0;
  bool applyGST = false;

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController
  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat percentFormatter = NumberFormat.percentPattern();

  void _calculateTax() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double income = double.parse(incomeController.text.replaceAll(',', ''));
      double deductions = double.parse(deductionsController.text.replaceAll(',', ''));
      double gstRate = applyGST ? double.parse(gstRateController.text) : 0.0;

      // Apply GST if the toggle is true
      if (applyGST) {
        gstAmount = income * gstRate / 100;
        income += gstAmount; // Add GST to income
      }

      taxableIncome = income - deductions;
      if (taxableIncome < 0) taxableIncome = 0;

      double tax = _computeTax(taxableIncome);

      setState(() {
        totalTax = tax;
        effectiveTaxRate = tax / income;
        showResults = true;
      });
    }
  }

  // Tax calculation based on slabs (modify as per your country's tax structure)
  double _computeTax(double income) {
    if (income <= 250000) {
      return 0; // No tax for income up to 250,000
    } else if (income <= 500000) {
      return (income - 250000) * 0.05; // 5% tax for income between 250,001 and 500,000
    } else if (income <= 1000000) {
      return 12500 + (income - 500000) * 0.2; // 20% tax for income between 500,001 and 1,000,000
    } else {
      return 112500 + (income - 1000000) * 0.3; // 30% tax for income above 1,000,000
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    incomeController.clear();
    deductionsController.clear();
    gstRateController.clear();

    setState(() {
      showResults = false;
      totalTax = 0;
      taxableIncome = 0;
      effectiveTaxRate = 0;
      gstAmount = 0;
      applyGST = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.income_tax_calculator ?? 'Income Tax Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
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
                  AppLocalizations.of(context)?.annual_income ?? 'Annual Income',
                  incomeController,
                  '${currencyController.selectedCurrency.value} 10,00,000',
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.deductions ?? 'Deductions',
                  deductionsController,
                  '${currencyController.selectedCurrency.value} 1,00,000',
                ),

                // GST Rate Field and Toggle
                Row(
                  children: [
                    Switch(
                      value: applyGST,
                      onChanged: (value) {
                        setState(() {
                          applyGST = value;
                        });
                      },
                    ),
                    Text(
                      applyGST ? AppLocalizations.of(context)?.apply_gst ?? 'Apply GST' : AppLocalizations.of(context)?.no_gst ?? 'No GST',
                      style: TextStyle(fontSize: Get.textScaleFactor * 14),
                    ),
                  ],
                ),

                if (applyGST)
                  _buildInputField(
                    AppLocalizations.of(context)?.gst_rate ?? 'GST Rate (%)',
                    gstRateController,
                    '18%',
                  ),

                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateTax, Colors.blue)),
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
            AppLocalizations.of(context)?.your_tax_results ?? 'Your Tax Calculation Results:',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: Get.height * 0.01),
          if (applyGST)
            _buildResultItem(
              AppLocalizations.of(context)?.gst_applied ?? 'GST Applied:',
              currencyFormatter.format(gstAmount),
            ),
          _buildResultItem(
            AppLocalizations.of(context)?.taxable_income ?? 'Taxable Income:',
            currencyFormatter.format(taxableIncome),
          ),
          _buildResultItem(
            AppLocalizations.of(context)?.total_income_tax ?? 'Total Income Tax:',
            currencyFormatter.format(totalTax),
          ),
          _buildResultItem(
            AppLocalizations.of(context)?.effective_tax_rate ?? 'Effective Tax Rate:',
            percentFormatter.format(effectiveTaxRate),
          ),
        ],
      ),
    ));
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: Get.textScaleFactor * 14)),
          Text(
            value,
            style: TextStyle(fontSize: Get.textScaleFactor * 14, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.tax_slab_info ?? 'Tax Slab Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('• ${AppLocalizations.of(context)?.slab_1 ?? "Up to ₹2,50,000: No tax"}'),
                Text('• ${AppLocalizations.of(context)?.slab_2 ?? "₹2,50,001 to ₹5,00,000: 5%"}'),
                Text('• ${AppLocalizations.of(context)?.slab_3 ?? "₹5,00,001 to ₹10,00,000: 20%"}'),
                Text('• ${AppLocalizations.of(context)?.slab_4 ?? "Above ₹10,00,000: 30%"}'),
                SizedBox(height: 10),
                Text(AppLocalizations.of(context)?.tax_note ?? 'Note: This is a simplified calculation and may not reflect all possible deductions or surcharges.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
