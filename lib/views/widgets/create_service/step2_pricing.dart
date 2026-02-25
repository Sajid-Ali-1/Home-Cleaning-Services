import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/views/widgets/create_service/base_price_section.dart';
import 'package:home_cleaning_app/views/widgets/create_service/pricing_info_card.dart';
import 'package:home_cleaning_app/views/widgets/create_service/pricing_options_section.dart';

class Step2Pricing extends StatelessWidget {
  const Step2Pricing({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description based on category
        Obx(() {
          final category = controller.selectedCategory.value;

          if (category == ServiceCategory.cleaning) {
            return PricingInfoCard(
              icon: Icons.access_time,
              title: 'Unit-based pricing',
              description:
                  'Define prices per hour, per room or any custom unit. Customers will choose how many units they need when booking.',
            );
          } else if (category == ServiceCategory.landscaping) {
            return PricingInfoCard(
              icon: Icons.attach_money,
              title: 'Layered services',
              description:
                  'Add multiple sub-services (mowing, trimming, etc.) each with its own unit price. Optionally include a base/visit fee.',
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(height: 24.h),
        // Pricing Options (for Cleaning or Landscaping)
        Obx(() {
          final category = controller.selectedCategory.value;

          if (category == ServiceCategory.cleaning ||
              category == ServiceCategory.landscaping) {
            return const PricingOptionsSection();
          }
          return const SizedBox.shrink();
        }),
        // Base Price (for Landscaping)
        Obx(() {
          final category = controller.selectedCategory.value;

          if (category == ServiceCategory.landscaping) {
            return const BasePriceSection();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
