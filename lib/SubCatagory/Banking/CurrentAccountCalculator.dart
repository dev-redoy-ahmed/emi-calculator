import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CurrentAccountCalculator extends StatefulWidget {
  @override
  _CurrentAccountCalculatorState createState() => _CurrentAccountCalculatorState();
}

class _CurrentAccountCalculatorState extends State<CurrentAccountCalculator> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  double currentBalance = 0;
  double overdraftLimit = 0;
  bool showResults = false;
  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();

  // Transactions list to display deposits and withdrawals
  List<Map<String, dynamic>> transactions = [];

  void _addTransaction(String type) {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text.replaceAll(',', ''));

      if (type == 'Deposit') {
        currentBalance += amount;
        transactions.add({"type": AppLocalizations.of(context)?.deposit ?? "Deposit", "amount": amount, "balance": currentBalance});
      } else if (type == 'Withdraw' && (currentBalance - amount >= -overdraftLimit)) {
        currentBalance -= amount;
        transactions.add({"type": AppLocalizations.of(context)?.withdrawal ?? "Withdrawal", "amount": amount, "balance": currentBalance});
      } else {
        Get.snackbar(AppLocalizations.of(context)?.error ?? 'Error', AppLocalizations.of(context)?.overdraft_limit_error ?? 'Cannot withdraw beyond your overdraft limit',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      setState(() {
        showResults = true;
      });

      amountController.clear();
    }
  }

  Future<void> _reset() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    bool confirmReset = await _showConfirmationDialog();
    if (confirmReset) {
      amountController.clear();
      setState(() {
        currentBalance = 0;
        overdraftLimit = 0;
        showResults = false;
        transactions.clear();
      });
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.confirm_reset ?? 'Confirm Reset'),
        content: Text(AppLocalizations.of(context)?.reset_confirmation ?? 'Are you sure you want to reset the account balance and history?'),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.current_account_calculator ?? 'Current Account Balance Tracker'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildInputField(AppLocalizations.of(context)?.transaction_amount ?? 'Transaction Amount', amountController, AppLocalizations.of(context)?.enter_amount ?? 'Enter amount'),
                _buildOverdraftField(),
                SizedBox(height: Get.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.deposit ?? 'Deposit', () => _addTransaction('Deposit'), Colors.green)),
                    SizedBox(width: Get.width * 0.02),
                    Expanded(child: _buildButton(AppLocalizations.of(context)?.withdraw ?? 'Withdraw', () => _addTransaction('Withdraw'), Colors.red)),
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

  Widget _buildOverdraftField() {
    return Container(
      margin: EdgeInsets.only(bottom: Get.height * 0.01), // Responsive margin
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.30, // Responsive width for label
            child: Text(AppLocalizations.of(context)?.overdraft_limit ?? 'Overdraft Limit'),
          ),
          Expanded(
            child: Container(
              height: 40, // Reduced fixed height
              child: TextFormField(
                initialValue: overdraftLimit.toString(),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: AppLocalizations.of(context)?.enter_overdraft_limit ?? 'Enter overdraft limit',
                  hintStyle: TextStyle(color: Colors.grey.shade500), // Light hint text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced vertical padding
                ),
                style: TextStyle(fontSize: Get.textScaleFactor * 14), // Responsive text size
                onChanged: (value) {
                  setState(() {
                    overdraftLimit = double.tryParse(value.replaceAll(',', '')) ?? 0;
                  });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.transaction_history ?? 'Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          children: [
            TableRow(children: [
              Padding(padding: EdgeInsets.all(8.0), child: Text(AppLocalizations.of(context)?.type ?? 'Type', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8.0), child: Text(AppLocalizations.of(context)?.amount ?? 'Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8.0), child: Text(AppLocalizations.of(context)?.balance ?? 'Balance', style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
            ...transactions.map((transaction) {
              return TableRow(children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text(transaction["type"])),
                Padding(padding: EdgeInsets.all(8.0), child: Text(currencyFormatter.format(transaction["amount"]))),
                Padding(padding: EdgeInsets.all(8.0), child: Text(currencyFormatter.format(transaction["balance"]))),
              ]);
            }).toList(),
          ],
        ),
        SizedBox(height: 20),
        Text('${AppLocalizations.of(context)?.current_balance ?? 'Current Balance'}: ${currencyFormatter.format(currentBalance)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
