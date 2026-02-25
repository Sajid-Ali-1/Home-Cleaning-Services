import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServiceDetailsHeader extends StatelessWidget {
  const ServiceDetailsHeader({
    super.key,
    this.onBackTap,
    this.onNotificationTap,
  });

  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBackTap ?? () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.of(context).primaryText,
              size: 24.sp,
            ),
          ),
          // Title
          Expanded(
            child: Text(
              'Service Details',
              style: AppTheme.of(context).bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          // Notification icon
          IconButton(
            onPressed: onNotificationTap,
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.of(context).primaryText,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

