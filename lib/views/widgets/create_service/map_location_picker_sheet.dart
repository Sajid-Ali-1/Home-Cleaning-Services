import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class MapLocationPickerSheet extends StatefulWidget {
  const MapLocationPickerSheet({super.key, required this.controller});

  final CreateServiceFormController controller;

  @override
  State<MapLocationPickerSheet> createState() => _MapLocationPickerSheetState();
}

class _MapLocationPickerSheetState extends State<MapLocationPickerSheet> {
  late final MapController _mapController;
  late LatLng _initialCenter;
  LatLng? _pickedPoint;

  @override
  void initState() {
    super.initState();
    final lat = widget.controller.serviceLatitude.value ?? 37.7749;
    final lng = widget.controller.serviceLongitude.value ?? -122.4194;
    _initialCenter = LatLng(lat, lng);
    _pickedPoint = widget.controller.serviceLatitude.value != null
        ? _initialCenter
        : null;
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          top: 8.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: theme.secondaryText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            Text(
              'Pin your service location',
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              'Drag the map and double tap to drop a pin. Tap confirm when ready.',
              textAlign: TextAlign.center,
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 13,
                    onTap: (tapPosition, latLng) {
                      setState(() => _pickedPoint = latLng);
                    },
                    onLongPress: (tapPosition, latLng) {
                      setState(() => _pickedPoint = latLng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'home_cleaning_app',
                    ),
                    if (_pickedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pickedPoint!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.place,
                              size: 34.sp,
                              color: theme.accent1,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  color: theme.accent1,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Double tap anywhere to move the marker precisely.',
                    style: theme.bodySmall.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickedPoint == null ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accent1,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Use this location',
                  style: theme.bodyMedium.copyWith(
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

  Future<void> _handleConfirm() async {
    final point = _pickedPoint ?? _initialCenter;
    await widget.controller.setLocationFromMap(
      latitude: point.latitude,
      longitude: point.longitude,
    );
    if (!mounted) return;
    Get.back();
  }
}

