import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/models/unit_price_option.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicePricingOptionsSection extends StatelessWidget {
  const ServicePricingOptionsSection({super.key, required this.isCustomerView});

  final bool isCustomerView;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();
    final service = controller.currentService.value ?? controller.service;
    final isLandscaping =
        service.serviceCategory == ServiceCategory.landscaping;

    final hasPricingOptions = (service.pricingOptions?.isNotEmpty ?? false);
    final hasBasePrice = service.basePrice != null && service.basePrice! > 0;

    // Show error message if service has no pricing options (should not happen for valid services)
    if (!hasPricingOptions && !hasBasePrice) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.of(context).error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.of(context).error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.of(context).error,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'This service has no pricing options configured. Please contact the service provider.',
                  style: AppTheme.of(
                    context,
                  ).bodySmall.copyWith(color: AppTheme.of(context).error),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCustomerView
                ? (isLandscaping
                      ? 'Select Sub-Services'
                      : 'Select Service Option')
                : 'Pricing Options',
            style: AppTheme.of(
              context,
            ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          if (isCustomerView) ...[
            SizedBox(height: 4.h),
            Text(
              isLandscaping
                  ? 'Select one or more sub-services you need'
                  : 'Select your preferred service option',
              style: AppTheme.of(
                context,
              ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
            ),
          ],
          SizedBox(height: 12.h),
          if (hasPricingOptions)
            isCustomerView
                ? Obx(
                    () => Column(
                      children: service.pricingOptions!
                          .map(
                            (option) => _InteractivePricingOptionCard(
                              option: option,
                              isSelected: controller.isOptionSelected(option),
                              quantity: controller.getQuantityForOption(option),
                              onToggle: () => controller.toggleOption(option),
                              onIncrement: () =>
                                  controller.incrementQuantity(option),
                              onDecrement: () =>
                                  controller.decrementQuantity(option),
                              isLandscaping: isLandscaping,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Column(
                    children: service.pricingOptions!
                        .map(
                          (option) => _ReadOnlyPricingOptionCard(
                            option: option,
                            isLandscaping: isLandscaping,
                          ),
                        )
                        .toList(),
                  ),
        ],
      ),
    );
  }
}

class _InteractivePricingOptionCard extends StatelessWidget {
  const _InteractivePricingOptionCard({
    required this.option,
    required this.isSelected,
    required this.quantity,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.isLandscaping,
  });

  final UnitPriceOption option;
  final bool isSelected;
  final double quantity;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isLandscaping;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.of(context).accent1.withOpacity(0.1)
            : AppTheme.of(context).secondaryBackground,
        border: Border.all(
          color: isSelected
              ? AppTheme.of(context).accent1.withOpacity(0.3)
              : AppTheme.of(context).dividerColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio for cleaning (single selection) or Checkbox for landscaping (multiple)
              if (isLandscaping)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  activeColor: theme.accent1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                )
              else
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (_) => onToggle(),
                  activeColor: theme.accent1,
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isLandscaping ? option.name : 'Cleaning rate',
                            style: theme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accent1.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Selected',
                              style: theme.bodySmall.copyWith(
                                color: theme.accent1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '\$${option.pricePerUnit.toStringAsFixed(2)} / ${option.unitDisplay}',
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                    if (option.description != null &&
                        option.description!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        option.description!,
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isSelected) ...[
            SizedBox(height: 12.h),
            _QuantityStepper(
              quantity: quantity,
              unitLabel: option.unitName,
              allowDecimal: option.allowDecimal,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadOnlyPricingOptionCard extends StatelessWidget {
  const _ReadOnlyPricingOptionCard({
    required this.option,
    required this.isLandscaping,
  });

  final UnitPriceOption option;
  final bool isLandscaping;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLandscaping ? option.name : 'Cleaning rate',
            style: theme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${option.pricePerUnit.toStringAsFixed(2)} / ${option.unitDisplay}',
            style: theme.bodySmall.copyWith(color: theme.secondaryText),
          ),
          SizedBox(height: 4.h),
          Text(
            'Min: ${option.minQuantity} ${option.unitName}',
            style: theme.bodySmall.copyWith(color: theme.secondaryText),
          ),
          if (option.description != null && option.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                option.description!,
                style: theme.bodySmall.copyWith(color: theme.secondaryText),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.unitLabel,
    required this.allowDecimal,
    required this.onIncrement,
    required this.onDecrement,
  });

  final double quantity;
  final String unitLabel;
  final bool allowDecimal;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final quantityLabel = allowDecimal
        ? quantity.toStringAsFixed(1)
        : quantity.toStringAsFixed(0);
    return Row(
      children: [
        _StepperButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          backgroundColor: theme.textFieldColor,
        ),
        Expanded(
          child: Center(
            child: Text(
              '$quantityLabel $unitLabel',
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onPressed: onIncrement,
          backgroundColor: theme.accent1,
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        splashColor: Colors.transparent,
        icon: Icon(icon, color: iconColor ?? AppTheme.of(context).primaryText),
        onPressed: onPressed,
      ),
    );
  }
}
