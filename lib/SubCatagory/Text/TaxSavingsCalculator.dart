import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../l10n_controller/CountryChangeController.dart';

class TaxSavingsCalculator extends StatefulWidget {
  @override
  _TaxSavingsCalculatorState createState() => _TaxSavingsCalculatorState();
}

class _TaxSavingsCalculatorState extends State<TaxSavingsCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController totalIncomeController = TextEditingController();
  TextEditingController totalDeductionsController = TextEditingController();
  TextEditingController taxRateController = TextEditingController();
  TextEditingController gstRateController = TextEditingController();

  bool showResults = false;
  double taxSavings = 0;
  double newTaxableIncome = 0;
  double gstAmount = 0;
  double finalAmount = 0;
  bool isAddingGST = true; // Toggle between adding or removing GST

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController
  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();

  void _calculateTaxSavings() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double totalIncome = double.parse(totalIncomeController.text.replaceAll(',', ''));
      double totalDeductions = double.parse(totalDeductionsController.text.replaceAll(',', ''));
      double taxRate = double.parse(taxRateController.text) / 100;
      double gstRate = double.parse(gstRateController.text);

      // Calculate taxable income after deductions
      double taxableIncome = totalIncome - totalDeductions;
      double originalTax = totalIncome * taxRate;
      double newTax = taxableIncome * taxRate;

      // Calculate tax savings
      double savings = originalTax - newTax;

      // Calculate GST based on the toggle selection (Add GST or Remove GST)
      double gst;
      if (isAddingGST) {
        gst = taxableIncome * gstRate / 100;
        finalAmount = taxableIncome + gst;
      } else {
        gst = taxableIncome - (taxableIncome * (100 / (100 + gstRate)));
        finalAmount = taxableIncome - gst;
      }

      setState(() {
        newTaxableIncome = taxableIncome;
        taxSavings = savings;
        gstAmount = gst;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    totalIncomeController.clear();
    totalDeductionsController.clear();
    taxRateController.clear();
    gstRateController.clear();

    setState(() {
      showResults = false;
      taxSavings = 0;
      newTaxableIncome = 0;
      gstAmount = 0;
      finalAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.tax_savings_calculator ?? 'Tax Savings Calculator with GST'),
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
                _buildInputField(
                    AppLocalizations.of(context)?.total_income ?? 'Total Income',
                    totalIncomeController,
                    '${currencyController.selectedCurrency.value} 50,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.total_deductions ?? 'Total Deductions',
                    totalDeductionsController,
                    '${currencyController.selectedCurrency.value} 10,000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.tax_note ?? 'Tax Rate (%)',
                    taxRateController,
                    '20%' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.gst_rate ?? 'GST Rate (%)',
                    gstRateController,
                    '18%' // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),

                // Toggle between Add GST and Remove GST
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGSTToggle(AppLocalizations.of(context)?.add_gst ?? 'Add GST (+)', true),
                    _buildGSTToggle(AppLocalizations.of(context)?.remove_gst ?? 'Remove GST (-)', false),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),

                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateTaxSavings, Colors.blue)),
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
              height: 60, // Consistent height for all input fields
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Consistent padding
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

  Widget _buildGSTToggle(String label, bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<bool>(
          value: value,
          groupValue: isAddingGST,
          onChanged: (bool? newValue) {
            setState(() {
              isAddingGST = newValue!;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(fontSize: Get.textScaleFactor * 14),
        ),
      ],
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
            AppLocalizations.of(context)?.tax_savings_calculation ?? 'Tax Savings Calculation:',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            '${AppLocalizations.of(context)?.new_taxable_income ?? 'New Taxable Income'}: ${currencyController.selectedCurrency.value} ${currencyFormatter.format(newTaxableIncome)}',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            '${AppLocalizations.of(context)?.tax_savings ?? 'Tax Savings'}: ${currencyController.selectedCurrency.value} ${currencyFormatter.format(taxSavings)}',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            '${AppLocalizations.of(context)?.gst_amount ?? 'GST Amount'}: ${currencyController.selectedCurrency.value} ${currencyFormatter.format(gstAmount)}',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            isAddingGST
                ? '${AppLocalizations.of(context)?.final_amount_with_gst ?? 'Final Amount (with GST)'}: ${currencyController.selectedCurrency.value} ${currencyFormatter.format(finalAmount)}'
                : '${AppLocalizations.of(context)?.final_amount_without_gst ?? 'Final Amount (without GST)'}: ${currencyController.selectedCurrency.value} ${currencyFormatter.format(finalAmount)}',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    ));
  }
}
