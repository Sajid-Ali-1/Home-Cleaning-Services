import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServiceRadiusSection extends StatelessWidget {
  const ServiceRadiusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Radius *',
          style: AppTheme.of(
            context,
          ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          'How far are you willing to travel from your location?',
          style: AppTheme.of(
            context,
          ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Obx(
                () => Slider(
                  value: controller.serviceRadius.value,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label:
                      '${controller.serviceRadius.value.toStringAsFixed(1)} ${controller.radiusUnit.value}',
                  onChanged: (value) {
                    controller.setServiceRadius(value);
                  },
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              flex: 2,
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).textFieldColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${controller.serviceRadius.value.toStringAsFixed(1)} ${controller.radiusUnit.value}',
                    style: AppTheme.of(context).bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.of(context).accent1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Unit selector
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _UnitChip(
                  label: 'Kilometers',
                  unit: 'km',
                  isSelected: controller.radiusUnit.value == 'km',
                  onTap: () => controller.setRadiusUnit('km'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _UnitChip(
                  label: 'Miles',
                  unit: 'miles',
                  isSelected: controller.radiusUnit.value == 'miles',
                  onTap: () => controller.setRadiusUnit('miles'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String unit;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).accent1
              : AppTheme.of(context).textFieldColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).accent1
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.of(context).bodyMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : AppTheme.of(context).primaryText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
