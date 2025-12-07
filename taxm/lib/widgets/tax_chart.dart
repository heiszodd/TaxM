import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';

/// Pie chart showing tax distribution by band
class TaxChart extends StatelessWidget {
  final List<TaxBand> bands;

  const TaxChart({
    super.key,
    required this.bands,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (bands.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalTax = bands.fold<double>(0, (sum, band) => sum + band.tax);
    if (totalTax == 0) {
      return const SizedBox.shrink();
    }

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
          Text(
            'Tax Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildSections(totalTax),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                centerSpaceColor: isDark ? AppConstants.darkSurface : AppConstants.surface,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildLegend(theme, isDark),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double totalTax) {
    final colors = [
      AppConstants.primary,
      AppConstants.accent,
      const Color(0xFF9C88FF),
      const Color(0xFFF0932B),
      const Color(0xFFE84393),
    ];

    return bands.asMap().entries.map((entry) {
      final index = entry.key;
      final band = entry.value;
      final percentage = (band.tax / totalTax) * 100;

      return PieChartSectionData(
        value: band.tax,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: percentage < 5 ? null : Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length],
            ),
          ),
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }

  Widget _buildLegend(ThemeData theme, bool isDark) {
    final colors = [
      AppConstants.primary,
      AppConstants.accent,
      const Color(0xFF9C88FF),
      const Color(0xFFF0932B),
      const Color(0xFFE84393),
    ];

    return Wrap(
      spacing: AppConstants.spacingMd,
      runSpacing: AppConstants.spacingXs,
      children: bands.asMap().entries.map((entry) {
        final index = entry.key;
        final band = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppConstants.spacingXs),
            Text(
              band.rate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
