import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/customer_location_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicesFilteredEmptyState extends StatelessWidget {
  const ServicesFilteredEmptyState({super.key, required this.controller});

  final ServiceController controller;

  @override
  Widget build(BuildContext context) {
    // Check if location filtering might be the reason
    bool hasLocationFilter = false;
    try {
      final locationController = Get.find<CustomerLocationController>();
      hasLocationFilter = locationController.hasLocation.value;
    } catch (e) {
      // CustomerLocationController not available (cleaner mode)
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasLocationFilter ? Icons.location_off_outlined : Icons.search_off_outlined,
          size: 80.sp,
          color: AppTheme.of(context).secondaryText,
        ),
        SizedBox(height: 24.h),
        Text(
          hasLocationFilter
              ? 'No Services in Your Area'
              : 'No Results Found',
          style: AppTheme.of(context).displaySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          hasLocationFilter
              ? 'No services are available within the service radius of your current location. Try changing your location to see more services.'
              : 'Try adjusting your filters or search query\nto find what you\'re looking for.',
          style: AppTheme.of(
            context,
          ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        OutlinedButton(
          onPressed: () => controller.clearFilters(),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            side: BorderSide(color: AppTheme.of(context).accent1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Clear Filters',
            style: AppTheme.of(
              context,
            ).bodyMedium.copyWith(color: AppTheme.of(context).accent1),
          ),
        ),
      ],
    );
  }
}
