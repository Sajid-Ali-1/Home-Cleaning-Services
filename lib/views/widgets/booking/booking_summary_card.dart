import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/selected_pricing_option.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.selections,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final List<SelectedPricingOption> selections;
  final double subtotal;
  final double tax;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          ...selections.map(
            (selection) => Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${selection.option.name} x ${selection.quantity.toStringAsFixed(selection.option.allowDecimal ? 1 : 0)} ${selection.option.unitDisplay}',
                      style: theme.bodyMedium,
                    ),
                  ),
                  Text(
                    '\$${selection.total.toStringAsFixed(2)}',
                    style: theme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selections.isNotEmpty) Divider(color: theme.dividerColor),
          _PriceRow(label: 'Service Fee', amount: subtotal, theme: theme),
          SizedBox(height: 8.h),
          _PriceRow(label: 'Tax', amount: tax, theme: theme),
          SizedBox(height: 12.h),
          _PriceRow(
            label: 'Total Amount Due',
            amount: total,
            theme: theme,
            isEmphasized: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    required this.theme,
    this.isEmphasized = false,
  });

  final String label;
  final double amount;
  final AppTheme theme;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.bodyMedium.copyWith(
              fontWeight: isEmphasized ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.bodyMedium.copyWith(
            color: isEmphasized ? theme.accent1 : theme.primaryText,
            fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
