import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Card displaying tax calculation results
class ResultCard extends StatelessWidget {
  final TaxResult result;
  final bool showMonthly;

  const ResultCard({
    super.key,
    required this.result,
    this.showMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [AppConstants.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax Summary',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => _copyResult(context),
                icon: Icon(
                  Icons.copy,
                  color: AppConstants.primary,
                ),
                tooltip: 'Copy Result',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildResultRow(
            context,
            'Taxable Income',
            AppFormatters.formatCurrency(result.taxableIncome),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _buildResultRow(
            context,
            showMonthly ? 'Monthly Tax' : 'Annual Tax',
            AppFormatters.formatCurrency(showMonthly ? result.monthlyTax : result.annualTax),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _buildResultRow(
            context,
            'Net After Tax',
            AppFormatters.formatCurrency(result.netAnnualAfterTax),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value, {bool isPrimary = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isPrimary ? AppConstants.accent : (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary),
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _copyResult(BuildContext context) {
    final summary = '''
Tax Summary:
Taxable Income: ${AppFormatters.formatCurrency(result.taxableIncome)}
Annual Tax: ${AppFormatters.formatCurrency(result.annualTax)}
Monthly Tax: ${AppFormatters.formatCurrency(result.monthlyTax)}
Net After Tax: ${AppFormatters.formatCurrency(result.netAnnualAfterTax)}
''';

    Clipboard.setData(ClipboardData(text: summary)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tax summary copied to clipboard'),
          backgroundColor: AppConstants.accent,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}
