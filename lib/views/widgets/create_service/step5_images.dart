import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/images_empty_state.dart';
import 'package:home_cleaning_app/views/widgets/create_service/images_grid.dart';

class Step5Images extends StatelessWidget {
  const Step5Images({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add photos of your work. You can set any image as the cover.',
          style: AppTheme.of(context).bodyMedium.copyWith(
            color: AppTheme.of(context).secondaryText,
          ),
        ),
        SizedBox(height: 24.h),
        Obx(() {
          if (controller.selectedImages.isEmpty) {
            return const ImagesEmptyState();
          }
          return const ImagesGrid();
        }),
      ],
    );
  }
}
