import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class PricingInfoCard extends StatelessWidget {
  const PricingInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.of(context).accent1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.of(context).accent1.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.of(context).accent1.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppTheme.of(context).accent1, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.of(context).bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: AppTheme.of(context).bodySmall.copyWith(
                    color: AppTheme.of(context).secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
