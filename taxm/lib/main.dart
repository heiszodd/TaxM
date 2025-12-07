import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Format with commas
    String formatted = _formatNumber(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(String number) {
    if (number.isEmpty) return '';
    StringBuffer buffer = StringBuffer();
    int count = 0;
    for (int i = number.length - 1; i >= 0; i--) {
      buffer.write(number[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}

String formatNumberWithCommas(double number) {
  String numStr = number.toStringAsFixed(0);
  StringBuffer buffer = StringBuffer();
  int count = 0;
  for (int i = numStr.length - 1; i >= 0; i--) {
    buffer.write(numStr[i]);
    count++;
    if (count % 3 == 0 && i > 0) {
      buffer.write(',');
    }
  }
  return buffer.toString().split('').reversed.join('');
}

Map<String, dynamic> calculateNigeriaTax2025Detailed({
  required double grossIncome,
  double deductions = 0,
  double rentPaid = 0,
}) {
  // Rent Relief: 20% of rent, max 500k
  double rentRelief = (rentPaid * 0.20);
  if (rentRelief > 500000) rentRelief = 500000;

  // Taxable Income
  double taxable = grossIncome - deductions - rentRelief;
  if (taxable <= 0) {
    return {
      'taxableIncome': 0.0,
      'annualTax': 0.0,
      'monthlyTax': 0.0,
      'netAnnualAfterTax': grossIncome - deductions,
      'bandBreakdown': [],
    };
  }

  double tax = 0;
  double remaining = taxable;
  List<Map<String, dynamic>> breakdown = [];

  // Tax bands: {limit: rate} where limit is the upper bound of the bracket
  final bands = [
    {'limit': 800000.0, 'rate': 0.00},
    {'limit': 2200000.0, 'rate': 0.15},
    {'limit': 9000000.0, 'rate': 0.18},
    {'limit': 13000000.0, 'rate': 0.21},
    {'limit': 25000000.0, 'rate': 0.23},
    {'limit': double.infinity, 'rate': 0.25},
  ];

  double previousLimit = 0;
  for (var band in bands) {
    double limit = band['limit']!;
    double rate = band['rate']!;

    if (remaining <= previousLimit) break;

    double bracketEnd = limit;
    double bracketStart = previousLimit;
    double taxableInBracket = (remaining > bracketEnd ? bracketEnd : remaining) - bracketStart;
    if (taxableInBracket > 0) {
      double taxInBracket = taxableInBracket * rate;
      tax += taxInBracket;
      breakdown.add({
        'band': '₦${bracketStart.toStringAsFixed(0)} - ₦${limit == double.infinity ? '∞' : limit.toStringAsFixed(0)}',
        'rate': '${(rate * 100).toStringAsFixed(0)}%',
        'taxable': taxableInBracket,
        'tax': taxInBracket,
      });
    }
    previousLimit = limit;
  }

  double monthlyTax = tax / 12;
  double netAnnualAfterTax = grossIncome - deductions - tax;

  return {
    'taxableIncome': taxable,
    'annualTax': tax,
    'monthlyTax': monthlyTax,
    'netAnnualAfterTax': netAnnualAfterTax,
    'bandBreakdown': breakdown,
  };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TaxMatePage(),
    );
  }
}

class TaxMatePage extends StatefulWidget {
  const TaxMatePage({super.key});

  @override
  State<TaxMatePage> createState() => _TaxMatePageState();
}

class _TaxMatePageState extends State<TaxMatePage> {
  final TextEditingController _totalIncomeController = TextEditingController();
  Map<String, dynamic>? _taxResult;

  @override
  void initState() {
    super.initState();
    _taxResult = {
      'taxableIncome': 0.0,
      'annualTax': 0.0,
      'monthlyTax': 0.0,
      'netAnnualAfterTax': 0.0,
      'bandBreakdown': [],
    };
  }

  void _calculateTax() {
    String text = _totalIncomeController.text.replaceAll(',', '');
    double income = double.tryParse(text) ?? 0.0;
    Map<String, dynamic> result = calculateNigeriaTax2025Detailed(grossIncome: income);
    debugPrint('Income: $income, Result: $result');
    setState(() {
      _taxResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaxMate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _totalIncomeController,
              decoration: const InputDecoration(
                labelText: 'Total Income',
                prefixText: '₦',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [NumberInputFormatter()],
              onChanged: (value) => _calculateTax(),
              onSubmitted: (value) => _calculateTax(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculateTax,
              child: const Text('Calculate Tax'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taxable Income: ₦${(_taxResult?['taxableIncome'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Annual Tax: ₦${(_taxResult?['annualTax'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    'Net Annual After Tax: ₦${(_taxResult?['netAnnualAfterTax'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Breakdown:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...(_taxResult?['bandBreakdown'] as List<dynamic>? ?? []).map((band) => Text(
                        '${(band as Map<String, dynamic>)['band']}: ${(band as Map<String, dynamic>)['rate']} - Taxable: ₦${formatNumberWithCommas((band as Map<String, dynamic>)['taxable'])}, Tax: ₦${formatNumberWithCommas((band as Map<String, dynamic>)['tax'])}',
                        style: const TextStyle(fontSize: 14),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


