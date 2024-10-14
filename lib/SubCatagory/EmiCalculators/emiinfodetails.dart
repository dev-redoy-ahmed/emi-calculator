import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EMIDetailsPage extends StatelessWidget {
  final double amount;
  final double interest;
  final int period;
  final bool isYears;
  final double monthlyEMI;
  final double totalInterest;
  final double processingFees;
  final double totalPayment;

  EMIDetailsPage({
    required this.amount,
    required this.interest,
    required this.period,
    required this.isYears,
    required this.monthlyEMI,
    required this.totalInterest,
    required this.processingFees,
    required this.totalPayment,
  });

  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency();
  final NumberFormat numberFormatter = NumberFormat('#,##0.00');

  // Generate amortization schedule
  List<Map<String, dynamic>> _generateAmortizationSchedule() {
    List<Map<String, dynamic>> schedule = [];
    double balance = amount;
    double monthlyInterest = interest / 12 / 100;
    int totalMonths = isYears ? period * 12 : period;

    for (int i = 1; i <= totalMonths; i++) {
      double interestPayment = balance * monthlyInterest;
      double principalPayment = monthlyEMI - interestPayment;
      balance -= principalPayment;

      schedule.add({
        'month': i,
        'principal': principalPayment,
        'interest': interestPayment,
        'balance': balance,
      });
    }

    return schedule;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> schedule = _generateAmortizationSchedule();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.details ?? 'EMI Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSummaryTable(context),
              SizedBox(height: 20),
              _buildAmortizationSchedule(context, schedule),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        _buildTableRow(AppLocalizations.of(context)?.loan_amount ?? 'Amount', currencyFormatter.format(amount)),
        _buildTableRow(AppLocalizations.of(context)?.interest_rate ?? 'Interest %', interest.toStringAsFixed(2)),
        _buildTableRow(AppLocalizations.of(context)?.loan_period ?? 'Period (${isYears ? (AppLocalizations.of(context)?.years ?? "Years") : (AppLocalizations.of(context)?.months ?? "Months")})', period.toString()),
        _buildTableRow(AppLocalizations.of(context)?.monthly_emi ?? 'Monthly EMI', currencyFormatter.format(monthlyEMI)),
        _buildTableRow(AppLocalizations.of(context)?.total_interest ?? 'Total Interest', currencyFormatter.format(totalInterest)),
        _buildTableRow(AppLocalizations.of(context)?.processing_fees ?? 'Processing Fees', currencyFormatter.format(processingFees)),
        _buildTableRow(AppLocalizations.of(context)?.total_payment ?? 'Total Payment', currencyFormatter.format(totalPayment)),
      ],
    );
  }

  Widget _buildAmortizationSchedule(BuildContext context, List<Map<String, dynamic>> schedule) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          child: Table(
            border: TableBorder.all(color: Colors.white),
            children: [
              TableRow(
                children: [
                  AppLocalizations.of(context)?.months ?? 'Month',
                  AppLocalizations.of(context)?.principal_component ?? 'Principal',
                  AppLocalizations.of(context)?.interest_component ?? 'Interest',
                  AppLocalizations.of(context)?.outstanding_balance ?? 'Balance'
                ]
                    .map((header) => Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    header,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: schedule.map((row) {
            return TableRow(
              children: [
                row['month'].toString(),
                row['principal'].toStringAsFixed(2),
                row['interest'].toStringAsFixed(2),
                row['balance'].toStringAsFixed(2),
              ].map((cell) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(cell),
              )).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(label),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
