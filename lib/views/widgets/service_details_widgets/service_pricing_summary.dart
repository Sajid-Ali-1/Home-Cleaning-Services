import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/models/selected_pricing_option.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicePricingSummary extends StatelessWidget {
  const ServicePricingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();

    return Obx(() {
      if (controller.totalPrice.value <= 0) {
        return const SizedBox.shrink();
      }

      final selections = controller.selectedPricingOptions;
      final service = controller.currentService.value ?? controller.service;
      final hasBasePrice = service.basePrice != null && service.basePrice! > 0;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Summary',
              style: AppTheme.of(
                context,
              ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            if (selections.isNotEmpty)
              ...selections.map(
                (selection) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _SelectionRow(selection: selection),
                ),
              ),
            if (hasBasePrice) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _BasePriceRow(price: service.basePrice!),
              ),
            ],
            _PricingRow(
              label: 'Sub-total',
              amount: controller.servicesSubtotal.value,
            ),
            SizedBox(height: 8.h),
            _PricingRow(
              label: 'Taxes & Fees',
              amount: controller.taxesAndFees.value,
            ),
            SizedBox(height: 12.h),
            Divider(color: AppTheme.of(context).dividerColor),
            SizedBox(height: 12.h),
            _PricingRow(
              label: 'Total',
              amount: controller.totalPrice.value,
              isTotal: true,
            ),
          ],
        ),
      );
    });
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({required this.selection});

  final SelectedPricingOption selection;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selection.option.name,
                style: AppTheme.of(
                  context,
                ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2.h),
              Text(
                '${selection.quantity} ${selection.option.unitName}',
                style: AppTheme.of(
                  context,
                ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
              ),
            ],
          ),
        ),
        Text(
          '\$${selection.total.toStringAsFixed(2)}',
          style: AppTheme.of(
            context,
          ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BasePriceRow extends StatelessWidget {
  const _BasePriceRow({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Fee',
                style: AppTheme.of(
                  context,
                ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2.h),
              Text(
                'Added to every booking',
                style: AppTheme.of(
                  context,
                ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
              ),
            ],
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: AppTheme.of(
            context,
          ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.of(context).bodyMedium.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: AppTheme.of(context).bodyMedium.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? AppTheme.of(context).accent1
                : AppTheme.of(context).primaryText,
          ),
        ),
      ],
    );
  }
}
