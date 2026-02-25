import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/models/service_image_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ImageItem extends StatelessWidget {
  const ImageItem({
    super.key,
    required this.image,
    required this.index,
    required this.isCover,
  });

  final ServiceImageModel image;
  final int index;
  final bool isCover;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: image.isExisting && image.url != null
              ? Image.network(
                  image.url!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.of(context).textFieldColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              : image.file != null
                  ? Image.file(
                      image.file!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : _buildPlaceholder(context),
        ),
        // Cover badge
        if (isCover)
          Positioned(
            top: 8.h,
            left: 8.w,
            child: _CoverBadge(),
          ),
        // Actions overlay
        Positioned(
          top: 8.h,
          right: 8.w,
          child: _ImageActions(
            index: index,
            isCover: isCover,
            onSetCover: () => controller.setCoverImage(index),
            onRemove: () => controller.removeImage(index),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.of(context).textFieldColor,
      child: Icon(
        Icons.broken_image,
        color: AppTheme.of(context).secondaryText,
        size: 24.sp,
      ),
    );
  }
}

class _CoverBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.of(context).accent1,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        'Cover',
        style: AppTheme.of(context).labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ImageActions extends StatelessWidget {
  const _ImageActions({
    required this.index,
    required this.isCover,
    required this.onSetCover,
    required this.onRemove,
  });

  final int index;
  final bool isCover;
  final VoidCallback onSetCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Set as cover button
        if (!isCover)
          GestureDetector(
            onTap: onSetCover,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_outline,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
        if (!isCover) SizedBox(width: 8.w),
        // Remove button
        GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}
