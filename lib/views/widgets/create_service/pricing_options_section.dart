import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/empty_pricing_state.dart';
import 'package:home_cleaning_app/views/widgets/create_service/pricing_option_card.dart';

class PricingOptionsSection extends StatelessWidget {
  const PricingOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Obx(() {
      final category = controller.selectedCategory.value;
      return _PricingOptionsBody(category: category);
    });
  }
}

class _PricingOptionsBody extends StatelessWidget {
  const _PricingOptionsBody({required this.category});

  final ServiceCategory? category;

  bool get isLandscaping => category == ServiceCategory.landscaping;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLandscaping ? 'Sub-services & pricing' : 'Pricing',
                  style: AppTheme.of(
                    context,
                  ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Obx(
                  () => Text(
                    controller.pricingOptions.isEmpty
                        ? 'Add at least one option'
                        : '${controller.pricingOptions.length} option${controller.pricingOptions.length > 1 ? 's' : ''} added',
                    style: AppTheme.of(context).bodySmall.copyWith(
                      color: AppTheme.of(context).secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: AppTheme.of(context).accent1,
                size: 22.sp,
              ),
              tooltip: 'Add another option',
              onPressed: controller.addPricingOption,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.pricingOptions.isEmpty) {
            return EmptyPricingState(onAddOption: controller.addPricingOption);
          }
          return Column(
            children: [
              ...controller.pricingOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Obx(
                  () => PricingOptionCard(
                    index: index,
                    option: option,
                    category: category,
                    showDelete: true,
                    isExpanded: controller.expandedCardIndex.value == index,
                    onToggleExpansion: () =>
                        controller.toggleCardExpansion(index),
                  ),
                );
              }),
              SizedBox(height: 12.h),
            ],
          );
        }),
      ],
    );
  }
}
