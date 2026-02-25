import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/customer_location_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/map/customer_map_location_picker_sheet.dart';

class CustomerLocationSelector extends StatelessWidget {
  const CustomerLocationSelector({super.key});

  Future<void> _openLocationOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const _LocationOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<CustomerLocationController>();

    return Obx(() {
      final hasLocation = locationController.hasLocation.value;
      final isGettingLocation = locationController.isGettingLocation.value;
      final address = locationController.address.value;

      return GestureDetector(
        onTap: () => _openLocationOptions(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.of(context).textFieldColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasLocation
                  ? AppTheme.of(context).accent1.withOpacity(0.3)
                  : AppTheme.of(context).borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppTheme.of(context).accent1.withOpacity(0.1)
                      : AppTheme.of(context).secondaryText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  hasLocation ? Icons.location_on : Icons.location_off,
                  color: hasLocation
                      ? AppTheme.of(context).accent1
                      : AppTheme.of(context).secondaryText,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isGettingLocation)
                      Text(
                        'Getting your location...',
                        style: AppTheme.of(context).bodyMedium.copyWith(
                          color: AppTheme.of(context).secondaryText,
                        ),
                      )
                    else if (hasLocation && address.isNotEmpty)
                      Text(
                        address,
                        style: AppTheme.of(
                          context,
                        ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Set your location to see nearby services',
                        style: AppTheme.of(context).bodyMedium.copyWith(
                          color: AppTheme.of(context).secondaryText,
                        ),
                      ),
                    if (hasLocation && !isGettingLocation) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Tap to change location',
                        style: AppTheme.of(context).bodySmall.copyWith(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isGettingLocation)
                SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.of(context).accent1,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.of(context).secondaryText,
                  size: 24.sp,
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _LocationOptionsSheet extends StatelessWidget {
  const _LocationOptionsSheet();

  Future<void> _openMapPicker(BuildContext context) async {
    Navigator.pop(context); // Close options sheet first
    await Future.delayed(const Duration(milliseconds: 300));
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const CustomerMapLocationPickerSheet(),
    );
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
                          Navigator.pop(context);
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
                onPressed: () => _openMapPicker(context),
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
