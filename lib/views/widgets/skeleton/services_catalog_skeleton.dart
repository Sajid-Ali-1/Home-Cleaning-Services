import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/views/widgets/skeleton/skeleton_box.dart';
import 'package:home_cleaning_app/views/widgets/skeleton/service_card_skeleton.dart';

class ServicesCatalogSkeleton extends StatelessWidget {
  const ServicesCatalogSkeleton({
    super.key,
    this.isCleaner = false,
    this.isListView = false,
  });

  final bool isCleaner;
  final bool isListView;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Row(
          children: [
            SkeletonBox(width: 100.w, height: 24.h),
            const Spacer(),
            SkeletonBox(
              width: 40.w,
              height: 40.w,
              borderRadius: BorderRadius.circular(20.r),
            ),
            SizedBox(width: 8.w),
            SkeletonBox(
              width: 40.w,
              height: 40.w,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Search bar skeleton
        Row(
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 48.h,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            SkeletonBox(
              width: 48.w,
              height: 48.w,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ],
        ),
        SizedBox(height: 19.h),
        // Welcome section skeleton (only for customers)
        if (!isCleaner) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 150.w, height: 28.h),
              SizedBox(height: 4.h),
              SkeletonBox(width: 200.w, height: 16.h),
            ],
          ),
          SizedBox(height: 16.h),
        ],
        // Category chips skeleton
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 140.w, height: 20.h),
                SkeletonBox(
                  width: 40.w,
                  height: 40.w,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                SkeletonBox(
                  width: 100.w,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                SizedBox(width: 8.w),
                SkeletonBox(
                  width: 100.w,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                SizedBox(width: 8.w),
                SkeletonBox(
                  width: 100.w,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Services skeleton
        Expanded(
          child: isListView
              ? ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ServiceCardSkeleton(isListView: true);
                  },
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.45,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return const ServiceCardSkeleton(isListView: false);
                  },
                ),
        ),
      ],
    );
  }
}
