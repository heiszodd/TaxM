import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/tax_provider.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';
import '../widgets/currency_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';
import '../widgets/band_breakdown.dart';
import '../widgets/tax_chart.dart';

/// Main home page for the TaxMate app
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taxInput = ref.watch(taxInputProvider);
    final taxResult = ref.watch(taxResultProvider);
    final showMonthly = ref.watch(showMonthlyProvider);

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkMutedBg : AppConstants.mutedBg,
      appBar: AppBar(
        title: Text(
          'TaxMate',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            onPressed: () => ref.read(showMonthlyProvider.notifier).toggle(),
            icon: Icon(
              showMonthly ? Icons.calendar_view_month : Icons.calendar_today,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
            tooltip: showMonthly ? 'Show annual' : 'Show monthly',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Calculate your Nigeria personal income tax in seconds',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Input Card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkSurface : AppConstants.surface,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      boxShadow: const [AppConstants.softShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        CurrencyField(
                          label: 'Total Annual Income',
                          hint: 'Enter your annual income',
                          initialValue: taxInput.grossIncome,
                          onChanged: (value) => ref.read(taxInputProvider.notifier).updateGrossIncome(value),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        CurrencyField(
                          label: 'Allowable Deductions',
                          hint: 'Enter deductions',
                          initialValue: taxInput.deductions,
                          onChanged: (value) => ref.read(taxInputProvider.notifier).updateDeductions(value),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        CurrencyField(
                          label: 'Annual Rent Paid',
                          hint: 'Enter rent paid',
                          initialValue: taxInput.rentPaid,
                          onChanged: (value) => ref.read(taxInputProvider.notifier).updateRentPaid(value),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'Calculate Tax',
                                onPressed: () => ref.read(taxResultProvider.notifier).recalculate(taxInput),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            TextButton(
                              onPressed: () => ref.read(taxInputProvider.notifier).reset(),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: AppConstants.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Debug banner (only in debug mode)
                        if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                          const SizedBox(height: AppConstants.spacingMd),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingSm),
                            decoration: BoxDecoration(
                              color: AppConstants.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Debug: ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primary,
                                  ),
                                ),
                                ...List.generate(
                                  TaxInput.sampleData.length,
                                  (index) => TextButton(
                                    onPressed: () => ref.read(taxInputProvider.notifier).loadSample(index),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: AppConstants.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // Results
                  taxResult.when(
                    data: (result) => result != null ? _buildResults(context, ref, result, showMonthly) : const SizedBox(),
                    loading: () => _buildLoadingResults(context),
                    error: (error, stack) => _buildErrorResults(context, error),
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // Footer
                  Center(
                    child: Text(
                      'Built with ❤️ for Nigerian taxpayers',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, WidgetRef ref, TaxResult result, bool showMonthly) {
    return Column(
      children: [
        // Result Card
        ResultCard(
          result: result,
          showMonthly: showMonthly,
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // Chart
        TaxChart(bands: result.bandBreakdown),
        const SizedBox(height: AppConstants.spacingMd),

        // Breakdown
        BandBreakdown(bands: result.bandBreakdown),
      ],
    );
  }

  Widget _buildLoadingResults(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [AppConstants.softShadow],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorResults(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [AppConstants.softShadow],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppConstants.error,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Calculation Error',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppConstants.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
