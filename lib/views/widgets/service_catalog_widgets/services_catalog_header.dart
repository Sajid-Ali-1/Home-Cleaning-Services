import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/customer_location_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/map/customer_map_location_picker_sheet.dart';

class ServicesCatalogHeader extends StatelessWidget {
  const ServicesCatalogHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  Future<void> _openLocationOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: AppTheme.of(context).secondaryBackground,
      builder: (_) => _LocationOptionsSheet(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isCleaner = authController.userModel?.userType == UserType.cleaner;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: isCleaner ? 0 : 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCleaner ? 'My Services' : 'Services',
                  style: AppTheme.of(context).displaySmall,
                ),
                // Location Selector (only for customers)
                if (!isCleaner) ...[
                  SizedBox(height: 8.h),
                  _LocationSelectorInHeader(
                    onTap: () => _openLocationOptions(context),
                  ),
                ],
              ],
            ),
          ),
          // const Spacer(),
          // Notification Icon
          IconButton(
            onPressed: onNotificationTap,
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.of(context).primaryText,
              size: 24.sp,
            ),
          ),
          // // Profile Icon
          // IconButton(
          //   onPressed: onProfileTap,
          //   icon: Icon(
          //     Icons.person_outline,
          //     color: AppTheme.of(context).primaryText,
          //     size: 24.sp,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _LocationSelectorInHeader extends StatelessWidget {
  const _LocationSelectorInHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<CustomerLocationController>();

    return Obx(() {
      final hasLocation = locationController.hasLocation.value;
      final isGettingLocation = locationController.isGettingLocation.value;
      final address = locationController.address.value;

      return GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasLocation ? Icons.location_on : Icons.location_off,
              color: hasLocation
                  ? AppTheme.of(context).accent1
                  : AppTheme.of(context).secondaryText,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: isGettingLocation
                  ? Text(
                      'Getting location...',
                      style: AppTheme.of(context).bodySmall.copyWith(
                        color: AppTheme.of(context).secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : hasLocation && address.isNotEmpty
                  ? Text(
                      address,
                      style: AppTheme.of(context).bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      'Set location',
                      style: AppTheme.of(context).bodySmall.copyWith(
                        color: AppTheme.of(context).secondaryText,
                      ),
                    ),
            ),
            if (isGettingLocation)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: SizedBox(
                  width: 14.sp,
                  height: 14.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.of(context).accent1,
                    ),
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppTheme.of(context).secondaryText,
                size: 18.sp,
              ),
          ],
        ),
      );
    });
  }
}

class _LocationOptionsSheet extends StatelessWidget {
  const _LocationOptionsSheet({required this.parentContext});

  final BuildContext parentContext;

  Future<void> _openMapPicker() async {
    Navigator.pop(parentContext); // Close options sheet first
    await Future.delayed(const Duration(milliseconds: 300));
    // Use the parent context which is still valid
    if (parentContext.mounted) {
      await showModalBottomSheet(
        context: parentContext,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        backgroundColor: AppTheme.of(parentContext).secondaryBackground,
        builder: (_) => const CustomerMapLocationPickerSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<CustomerLocationController>();
    final serviceController = Get.find<ServiceController>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            Text(
              'Change Location',
              style: AppTheme.of(
                context,
              ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose how you want to set your location',
              style: AppTheme.of(
                context,
              ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
            ),
            SizedBox(height: 20.h),
            // Use Current Location button
            Obx(() {
              final isGettingLocation =
                  locationController.isGettingLocation.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isGettingLocation
                      ? null
                      : () async {
                          Get.back();
                          await locationController.getCurrentLocation();
                          serviceController.applyFilters();
                        },
                  icon: isGettingLocation
                      ? SizedBox(
                          width: 18.sp,
                          height: 18.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.my_location, size: 20.sp),
                  label: Text(
                    isGettingLocation
                        ? 'Getting Location...'
                        : 'Use Current Location',
                    style: AppTheme.of(context).bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.of(context).accent1,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                ),
              );
            }),
            SizedBox(height: 12.h),
            // Pick from Map button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: Icon(
                  Icons.map_outlined,
                  size: 20.sp,
                  color: AppTheme.of(context).accent1,
                ),
                label: Text(
                  'Pick from Map',
                  style: AppTheme.of(context).bodyMedium.copyWith(
                    color: AppTheme.of(context).accent1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(
                    color: AppTheme.of(context).accent1,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
