import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/skeleton/skeleton_box.dart';

class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({
    super.key,
    this.isListView = false,
  });

  final bool isListView;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isListView ? double.infinity : null,
      margin: EdgeInsets.only(bottom: isListView ? 12.h : 0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          SkeletonBox(
            width: double.infinity,
            height: 160.h,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          // Content skeleton
          Padding(
            padding: EdgeInsets.all(13.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: double.infinity, height: 16.h),
                          SizedBox(height: 6.h),
                          SkeletonBox(width: 120.w, height: 16.h),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SkeletonBox(width: 40.w, height: 16.h),
                  ],
                ),
                SizedBox(height: 6.h),
                // Description
                SkeletonBox(width: double.infinity, height: 12.h),
                SizedBox(height: 4.h),
                SkeletonBox(width: 150.w, height: 12.h),
                SizedBox(height: 6.h),
                // Location
                SkeletonBox(width: 100.w, height: 12.h),
                SizedBox(height: 8.h),
                // Button
                SkeletonBox(
                  width: double.infinity,
                  height: 40.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

