import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServiceAboutSection extends StatelessWidget {
  const ServiceAboutSection({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Service',
            style: AppTheme.of(
              context,
            ).headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Text(
            service.description ?? 'No description available for this service.',
            style: AppTheme.of(context).bodyMedium.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
