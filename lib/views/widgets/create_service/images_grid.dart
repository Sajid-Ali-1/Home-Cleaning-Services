import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/image_item.dart';

class ImagesGrid extends StatelessWidget {
  const ImagesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: controller.selectedImages.length,
            itemBuilder: (context, index) {
              final isCover = controller.coverImageIndex.value == index;
              return ImageItem(
                image: controller.selectedImages[index],
                index: index,
                isCover: isCover,
              );
            },
          ),
          SizedBox(height: 16.h),
          if (controller.selectedImages.length < 10)
            _AddMoreButton(onTap: () => controller.pickImages()),
        ],
      );
    });
  }
}

class _AddMoreButton extends StatelessWidget {
  const _AddMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        Icons.add_photo_alternate,
        color: AppTheme.of(context).accent1,
      ),
      label: Text(
        'Add More Images',
        style: AppTheme.of(
          context,
        ).bodyMedium.copyWith(color: AppTheme.of(context).accent1),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppTheme.of(context).accent1, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
