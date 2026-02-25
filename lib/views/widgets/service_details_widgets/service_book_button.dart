import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';

class ServiceBookButton extends StatelessWidget {
  const ServiceBookButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();
    final theme = AppTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final total = controller.totalPrice.value;
          final label = total > 0
              ? 'Book for \$${total.toStringAsFixed(2)}'
              : 'Book Service';
          final isEnabled = controller.canBook;
          return CustomButton(
            buttonText: label,
            onTap: isEnabled ? () => controller.bookService() : null,
            isLoading: controller.isBooking.value,
            buttonColor: isEnabled ? theme.accent1 : theme.textFieldColor,
            style: AppTheme.of(context).displaySmall.copyWith(
              color: isEnabled ? Colors.white : theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ),
    );
  }
}
