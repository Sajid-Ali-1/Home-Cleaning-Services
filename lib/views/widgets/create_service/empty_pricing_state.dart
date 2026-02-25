import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class EmptyPricingState extends StatelessWidget {
  const EmptyPricingState({super.key, required this.onAddOption});

  final VoidCallback onAddOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppTheme.of(context).textFieldColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.of(context).accent1.withOpacity(0.2),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.of(context).accent1.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_business_outlined,
              size: 32.sp,
              color: AppTheme.of(context).accent1,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No pricing options yet',
            style: AppTheme.of(context).bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.of(context).primaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first pricing option to get started.\nExample: 2 hours for \$50',
            style: AppTheme.of(context).bodySmall.copyWith(
              color: AppTheme.of(context).secondaryText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onAddOption,
            icon: Icon(Icons.add, size: 20.sp, color: Colors.white),
            label: Text(
              'Add First Option',
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).accent1,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
