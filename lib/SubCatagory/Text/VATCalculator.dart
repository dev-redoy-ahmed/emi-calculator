import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../l10n_controller/CountryChangeController.dart';

class VATCalculator extends StatefulWidget {
  @override
  _VATCalculatorState createState() => _VATCalculatorState();
}

class _VATCalculatorState extends State<VATCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController amountController = TextEditingController();
  TextEditingController vatRateController = TextEditingController();

  bool showResults = false;
  double vatAmount = 0;
  double totalAmount = 0;
  bool isAddingVAT = true; // Toggle between adding or removing VAT

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController
  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();

  void _calculateVAT() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));
      double vatRate = double.parse(vatRateController.text);

      double vat;
      double total;

      if (isAddingVAT) {
        // Adding VAT
        vat = amount * vatRate / 100;
        total = amount + vat;
      } else {
        // Removing VAT
        vat = amount - (amount * (100 / (100 + vatRate)));
        total = amount - vat;
      }

      setState(() {
        vatAmount = vat;
        totalAmount = total;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    amountController.clear();
    vatRateController.clear();

    setState(() {
      showResults = false;
      vatAmount = 0;
      totalAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.vat_calculator ?? 'VAT Calculator'),
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
                    AppLocalizations.of(context)?.amount ?? 'Amount',
                    amountController,
                    '${currencyController.selectedCurrency.value} 1000' // Example formatted hint
                ),
                _buildInputField(
                    AppLocalizations.of(context)?.vat_rate ?? 'VAT Rate (%)',
                    vatRateController,
                    '18%' // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),

                // Toggle between Add VAT and Remove VAT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVATToggle(AppLocalizations.of(context)?.add_vat ?? 'Add VAT (+)', true),
                    _buildVATToggle(AppLocalizations.of(context)?.remove_vat ?? 'Remove VAT (-)', false),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),

                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateVAT, Colors.blue)),
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
              height: 60, // Adjust the height for consistency
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

  Widget _buildVATToggle(String label, bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<bool>(
          value: value,
          groupValue: isAddingVAT,
          onChanged: (bool? newValue) {
            setState(() {
              isAddingVAT = newValue!;
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
            AppLocalizations.of(context)?.vat_calculation ?? 'VAT Calculation:',
            style: TextStyle(fontSize: Get.textScaleFactor * 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: Get.height * 0.01),
          Table(
            border: TableBorder.all(color: Colors.grey),
            children: [
              _buildTableRow(AppLocalizations.of(context)?.initial_amount ?? 'Initial Amount', currencyFormatter.format(double.parse(amountController.text))),
              _buildTableRow(AppLocalizations.of(context)?.gst_amount ?? 'VAT Amount', currencyFormatter.format(vatAmount)),
              _buildTableRow(
                  isAddingVAT
                      ? AppLocalizations.of(context)?.total_amount_with_vat ?? 'Total Amount (with VAT)'
                      : AppLocalizations.of(context)?.total_amount_without_vat ?? 'Total Amount (without VAT)',
                  currencyFormatter.format(totalAmount)),
            ],
          ),
        ],
      ),
    ));
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
