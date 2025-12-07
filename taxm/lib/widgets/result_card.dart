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
