import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n_controller/CountryChangeController.dart';

class GSTCalculator extends StatefulWidget {
  @override
  _GSTCalculatorState createState() => _GSTCalculatorState();
}

class _GSTCalculatorState extends State<GSTCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController amountController = TextEditingController();
  TextEditingController gstRateController = TextEditingController();

  bool showResults = false;
  double gstAmount = 0;
  double totalAmount = 0;
  bool isAddingGST = true; // Toggle between adding/removing GST

  final CurrencyController currencyController = Get.find<CurrencyController>(); // Get CurrencyController

  final NumberFormat numberFormatter = NumberFormat("#,##0.00");

  void _calculateGST() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));
      double gstRate = double.parse(gstRateController.text);

      double gst;
      double total;

      if (isAddingGST) {
        // Adding GST
        gst = amount * gstRate / 100;
        total = amount + gst;
      } else {
        // Removing GST
        gst = amount - (amount * (100 / (100 + gstRate)));
        total = amount - gst;
      }

      setState(() {
        gstAmount = gst;
        totalAmount = total;
        showResults = true;
      });
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    amountController.clear();
    gstRateController.clear();

    setState(() {
      showResults = false;
      gstAmount = 0;
      totalAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.gst_calculator ?? 'GST Calculator'),
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
                  '${currencyController.selectedCurrency.value} 10,000', // Example formatted hint
                ),
                _buildInputField(
                  AppLocalizations.of(context)?.gst_rate ?? 'GST Rate (%)',
                  gstRateController,
                  '18%', // Example formatted hint
                ),
                SizedBox(height: Get.height * 0.02),

                // GST Toggle between Add and Remove
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
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.calculate ?? 'Calculate', _calculateGST, Colors.blue)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.reset ?? 'Reset', _reset, Colors.grey)),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),

                if (showResults) _buildResultsBox(),
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
              height: 60, // Adjust the height to your preference
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

  Widget _buildResultsBox() {
    return Obx(() => Container(
      margin: EdgeInsets.only(top: Get.height * 0.02),
      padding: EdgeInsets.all(Get.width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey),
            children: [
              _buildTableRow(AppLocalizations.of(context)?.initial_amount ?? 'Initial Amount', numberFormatter.format(double.parse(amountController.text))),
              _buildTableRow(AppLocalizations.of(context)?.gst_amount ?? 'GST Amount', numberFormatter.format(gstAmount)),
              _buildTableRow(
                isAddingGST
                    ? AppLocalizations.of(context)?.total_with_gst ?? 'Total Amount (with GST)'
                    : AppLocalizations.of(context)?.total_without_gst ?? 'Total Amount (without GST)',
                numberFormatter.format(totalAmount),
              ),
            ],
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            '(CGST : ${(gstAmount / 2).toStringAsFixed(2)} , SGST : ${(gstAmount / 2).toStringAsFixed(2)})',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Get.textScaleFactor * 12,
              color: Colors.grey[700],
            ),
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
