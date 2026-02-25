import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServiceInfoSection extends StatelessWidget {
  const ServiceInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();
    final service = controller.currentService.value ?? controller.service;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Category
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title ?? 'Untitled Service',
                      style: AppTheme.of(context).bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    if (service.serviceCategory != null)
                      _CategoryBadge(
                        category: service.serviceCategory!,
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Description
          if (service.description != null && service.description!.isNotEmpty) ...[
            Text(
              'About This Service',
              style: AppTheme.of(context).bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 12.h),
            Text(
              service.description!,
              style: AppTheme.of(context).bodyMedium.copyWith(
                    color: AppTheme.of(context).primaryText,
                    height: 1.6,
                  ),
            ),
            SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.category,
  });

  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    String label = category == ServiceCategory.cleaning
        ? 'Cleaning'
        : 'Landscaping';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.of(context).accent1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppTheme.of(context).accent1.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTheme.of(context).bodySmall.copyWith(
              color: AppTheme.of(context).accent1,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

