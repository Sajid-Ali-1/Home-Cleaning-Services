import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/map/location_map_preview.dart';

class ServiceLocationSection extends StatelessWidget {
  const ServiceLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();
    final locationText = controller.getServiceLocationText();
    final areaInfo = controller.getServiceAreaInfo();
    final latitude = (areaInfo?['latitude'] as num?)?.toDouble();
    final longitude = (areaInfo?['longitude'] as num?)?.toDouble();
    final radius = (areaInfo?['radius'] as num?)?.toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.of(context).accent1,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Service Location',
                style: AppTheme.of(
                  context,
                ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.of(context).accent1.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place,
                      color: AppTheme.of(context).accent1,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationText,
                            style: AppTheme.of(
                              context,
                            ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (areaInfo != null) ...[
                            SizedBox(height: 8.h),
                            _ServiceAreaInfo(areaInfo: areaInfo),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (latitude != null && longitude != null) ...[
                  SizedBox(height: 12.h),
                  LocationMapPreview(
                    latitude: latitude,
                    longitude: longitude,
                    radiusKm: radius,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceAreaInfo extends StatelessWidget {
  const _ServiceAreaInfo({required this.areaInfo});

  final Map<String, dynamic> areaInfo;

  @override
  Widget build(BuildContext context) {
    final radius = areaInfo['radius'] as num?;
    final radiusUnit = areaInfo['radiusUnit'] as String? ?? 'km';
    final latitude = areaInfo['latitude'] as num?;
    final longitude = areaInfo['longitude'] as num?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (radius != null && radius > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.of(context).accent1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_button_checked,
                  size: 14.sp,
                  color: AppTheme.of(context).accent1,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${radius.toStringAsFixed(1)} $radiusUnit service radius',
                  style: AppTheme.of(context).bodySmall.copyWith(
                    color: AppTheme.of(context).accent1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (latitude != null && longitude != null) ...[
          SizedBox(height: 8.h),
          Text(
            'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
            style: AppTheme.of(
              context,
            ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
          ),
        ],
      ],
    );
  }
}
