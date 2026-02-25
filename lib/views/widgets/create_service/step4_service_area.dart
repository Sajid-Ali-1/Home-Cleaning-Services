import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/location_picker.dart';
import 'package:home_cleaning_app/views/widgets/create_service/service_radius_section.dart';

class Step4ServiceArea extends StatelessWidget {
  const Step4ServiceArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your location and service radius',
          style: AppTheme.of(
            context,
          ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
        ),
        SizedBox(height: 24.h),
        // Location Picker
        const LocationPicker(),
        SizedBox(height: 24.h),
        // Service Radius
        const ServiceRadiusSection(),
        SizedBox(height: 16.h),
        // Info card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.of(context).accent1.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.of(context).accent1.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.of(context).accent1,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Your service will be shown to customers within the specified radius of your location. We use GPS coordinates to calculate distances accurately.',
                  style: AppTheme.of(context).bodySmall.copyWith(
                    color: AppTheme.of(context).primaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
