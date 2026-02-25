import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/utils/service_validators.dart';
import 'package:home_cleaning_app/views/widgets/custom_text_form_field.dart';

class Step1BasicInfo extends StatelessWidget {
  const Step1BasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about your service',
          style: AppTheme.of(
            context,
          ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
        ),
        SizedBox(height: 24.h),
        // Category Selection
        Text(
          'Service Category *',
          style: AppTheme.of(
            context,
          ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _CategoryChip(
                  label: 'Cleaning',
                  category: ServiceCategory.cleaning,
                  isSelected:
                      controller.selectedCategory.value ==
                      ServiceCategory.cleaning,
                  onTap: () => controller.setCategory(ServiceCategory.cleaning),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _CategoryChip(
                  label: 'Landscaping',
                  category: ServiceCategory.landscaping,
                  isSelected:
                      controller.selectedCategory.value ==
                      ServiceCategory.landscaping,
                  onTap: () =>
                      controller.setCategory(ServiceCategory.landscaping),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        // Title
        CustomTextFormField(
          controller: controller.titleController,
          validator: ServiceValidators.validateServiceTitle,
          labelText: 'Service Title *',
          hintText: 'e.g., Professional Home Cleaning',
          prefixIcon: Icons.title,
          onChanged: (_) => controller.validateStep1(),
        ),
        SizedBox(height: 16.h),
        // Description
        CustomTextFormField(
          controller: controller.descriptionController,
          validator: ServiceValidators.validateServiceDescription,
          labelText: 'Description *',
          hintText: 'Describe what your service includes...',
          prefixIcon: Icons.description,
          minLines: 5,
          maxLines: 8,
          onChanged: (_) => controller.validateStep1(),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).accent1
              : AppTheme.of(context).textFieldColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).accent1
                : AppTheme.of(context).textFieldColor,
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
