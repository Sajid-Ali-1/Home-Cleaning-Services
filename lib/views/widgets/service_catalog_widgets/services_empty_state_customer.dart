import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicesEmptyStateCustomer extends StatelessWidget {
  const ServicesEmptyStateCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icon with background
            Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: AppTheme.of(context).accent1.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_outlined,
                size: 80.sp,
                color: AppTheme.of(context).accent1,
              ),
            ),
            SizedBox(height: 32.h),
            // Title
            Text(
              'No Services Available',
              style: AppTheme.of(
                context,
              ).displayMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Description
            Text(
              'There are no services available at the moment.\nPlease check back later.',
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: AppTheme.of(context).secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            // Info card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.of(context).textFieldColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.refresh_outlined,
                    color: AppTheme.of(context).accent1,
                    size: 32.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'New services are added regularly',
                    style: AppTheme.of(
                      context,
                    ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Check back soon to discover amazing\nhome cleaning and landscaping services!',
                    style: AppTheme.of(context).bodySmall.copyWith(
                      color: AppTheme.of(context).secondaryText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
