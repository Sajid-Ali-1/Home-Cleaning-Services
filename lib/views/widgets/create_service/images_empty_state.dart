import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ImagesEmptyState extends StatelessWidget {
  const ImagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return GestureDetector(
      onTap: () => controller.pickImages(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 60.h),
        decoration: BoxDecoration(
          color: AppTheme.of(context).textFieldColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.of(context).accent1.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48.sp,
              color: AppTheme.of(context).accent1,
            ),
            SizedBox(height: 12.h),
            Text(
              'Tap to Add Images',
              style: AppTheme.of(context).bodyLarge.copyWith(
                color: AppTheme.of(context).accent1,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Add at least 1 image (max 10)',
              style: AppTheme.of(
                context,
              ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
