import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/map_location_picker_sheet.dart';
import 'package:home_cleaning_app/views/widgets/map/location_map_preview.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  Future<void> _openMapPicker(
    BuildContext context,
    CreateServiceFormController controller,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MapLocationPickerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Location *',
          style: AppTheme.of(
            context,
          ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          'Set your service location using GPS',
          style: AppTheme.of(
            context,
          ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
        ),
        SizedBox(height: 12.h),
        // Location display/input
        Obx(() {
          final hasLocation =
              controller.serviceLatitude.value != null &&
              controller.serviceLongitude.value != null;

          if (hasLocation) {
            return _LocationDisplay(
              address: controller.locationController.text,
              latitude: controller.serviceLatitude.value!,
              longitude: controller.serviceLongitude.value!,
              radius: controller.serviceRadius.value,
              onClear: () => controller.clearLocation(),
            );
          }

          return const _LocationInput();
        }),
        SizedBox(height: 12.h),
        // Action buttons
        Obx(() {
          final isBusy = controller.isGettingLocation.value;
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isBusy
                ? null
                : controller.getCurrentLocation,
                  icon: isBusy
                ? SizedBox(
                    width: 18.sp,
                    height: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(Icons.my_location,
                          size: 18.sp, color: Colors.white),
            label: Text(
                    isBusy ? 'Getting Location...' : 'Use Current Location',
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).accent1,
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
        ),
              SizedBox(width: 12.w),
              Tooltip(
                message:
                    'Open map picker (double tap to drop the pointer).',
                triggerMode: TooltipTriggerMode.tap,
                child: IconButton.filledTonal(
                  onPressed: isBusy
                      ? null
                      : () => _openMapPicker(context, controller),
                  icon: Icon(Icons.map_outlined, size: 22.sp),
                  color: AppTheme.of(context).accent1,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _LocationDisplay extends StatelessWidget {
  const _LocationDisplay({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.onClear,
  });

  final String address;
  final double latitude;
  final double longitude;
  final double radius;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.of(context).accent1,
              borderRadius: BorderRadius.circular(8.r),
            ),
                child:
                    Icon(Icons.location_on, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: AppTheme.of(
                    context,
                  ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                  style: AppTheme.of(context).bodySmall.copyWith(
                    color: AppTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppTheme.of(context).error,
              size: 20.sp,
            ),
            onPressed: onClear,
            tooltip: 'Clear location',
          ),
        ],
      ),
        ),
        SizedBox(height: 12.h),
        LocationMapPreview(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radius,
        ),
      ],
    );
  }
}

class _LocationInput extends StatelessWidget {
  const _LocationInput();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.of(context).textFieldColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.of(context).accent1.withOpacity(0.2),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_off,
            color: AppTheme.of(context).secondaryText,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No location set',
              style: AppTheme.of(
                context,
              ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
