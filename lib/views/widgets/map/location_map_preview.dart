import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.radiusKm,
    this.height,
    this.interactive = false,
  });

  final double latitude;
  final double longitude;
  final double? radiusKm;
  final double? height;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(latitude, longitude);
    final mapHeight = height ?? 180.h;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: mapHeight,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: latLng,
            initialZoom: 13,
            interactionOptions: interactive
                ? const InteractionOptions()
                : const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'home_cleaning_app',
            ),
            if (radiusKm != null && radiusKm! > 0)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: latLng,
                    color: AppTheme.of(context).accent1.withOpacity(0.15),
                    borderStrokeWidth: 1,
                    borderColor: AppTheme.of(context).accent1.withOpacity(0.5),
                    radius: radiusKm! * 1000,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: latLng,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on,
                    color: AppTheme.of(context).accent1,
                    size: 32.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

