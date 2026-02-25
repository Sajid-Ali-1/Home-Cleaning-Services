import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/skeleton/skeleton_box.dart';

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status row
          Row(
            children: [
              Expanded(
                child: SkeletonBox(width: double.infinity, height: 20.h),
              ),
              SizedBox(width: 12.w),
              SkeletonBox(
                width: 80.w,
                height: 24.h,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Date
          SkeletonBox(width: 180.w, height: 16.h),
          SizedBox(height: 4.h),
          // Time
          SkeletonBox(width: 140.w, height: 14.h),
          SizedBox(height: 12.h),
          // Price row
          Row(
            children: [
              SkeletonBox(
                width: 16.w,
                height: 16.h,
                borderRadius: BorderRadius.circular(8.r),
              ),
              SizedBox(width: 6.w),
              SkeletonBox(width: 100.w, height: 16.h),
            ],
          ),
          SizedBox(height: 12.h),
          // Person row
          Row(
            children: [
              SkeletonBox(
                width: 16.w,
                height: 16.h,
                borderRadius: BorderRadius.circular(8.r),
              ),
              SizedBox(width: 6.w),
              SkeletonBox(width: 150.w, height: 14.h),
            ],
          ),
          SizedBox(height: 16.h),
          // Action buttons
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              SkeletonBox(
                width: 80.w,
                height: 36.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
              SkeletonBox(
                width: 80.w,
                height: 36.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
