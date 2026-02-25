import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicePricingSection extends StatelessWidget {
  const ServicePricingSection({super.key, required this.controller});

  final ServiceDetailsController controller;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Details',
            style: AppTheme.of(context).headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (controller.totalPrice.value <= 0) {
              return Text(
                'Select a pricing option to see totals.',
                style: AppTheme.of(context)
                    .bodySmall
                    .copyWith(color: AppTheme.of(context).secondaryText),
              );
            }

            return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).textFieldColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _PricingRow(
                    label: 'Sub-total',
                    amount: controller.servicesSubtotal.value,
                    ),
                    SizedBox(height: 12.h),
                    _PricingRow(
                      label: 'Taxes & Fees',
                      amount: controller.taxesAndFees.value,
                    ),
                    SizedBox(height: 12.h),
                    Divider(
                      color: AppTheme.of(context).dividerColor,
                    ),
                    SizedBox(height: 12.h),
                    _PricingRow(
                      label: 'Total Price',
                      amount: controller.totalPrice.value,
                      isTotal: true,
                    ),
                  ],
                ),
            );
          }),
        ],
      ),
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
              ),
        ),
      ],
    );
  }
}

