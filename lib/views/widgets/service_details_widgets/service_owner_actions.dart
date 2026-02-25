import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/services/create_service_screen.dart';

class ServiceOwnerActions extends StatelessWidget {
  const ServiceOwnerActions({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final updated = await Get.to(
                    () => CreateServiceScreen(service: service),
                  );
                  if (updated == true &&
                      Get.isRegistered<ServiceDetailsController>()) {
                    final detailsController =
                        Get.find<ServiceDetailsController>();
                    await detailsController.loadServiceDetails();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(
                    color: AppTheme.of(context).accent1,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Edit Service',
                  style: AppTheme.of(context).bodyMedium.copyWith(
                    color: AppTheme.of(context).accent1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showDeleteConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Delete',
                  style: AppTheme.of(context).bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final serviceController = Get.find<ServiceController>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Service',
          style: AppTheme.of(
            context,
          ).bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this service? This action cannot be undone.',
          style: AppTheme.of(context).bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTheme.of(
                context,
              ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              if (service.serviceId != null && service.cleanerId != null) {
                final success = await serviceController.deleteService(
                  serviceId: service.serviceId!,
                  cleanerId: service.cleanerId!,
                );
                if (success) {
                  Get.back();
                }
              }
            },
            child: Text(
              'Delete',
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: AppTheme.of(context).error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
