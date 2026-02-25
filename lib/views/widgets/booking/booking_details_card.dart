import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class BookingDetailsCard extends StatelessWidget {
  const BookingDetailsCard({
    super.key,
    required this.serviceTitle,
    required this.serviceSubtitle,
    required this.slotDay,
    required this.slotTime,
    required this.onEditTap,
  });

  final String serviceTitle;
  final String serviceSubtitle;
  final String slotDay;
  final String slotTime;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Service Details',
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48.r,
                width: 48.r,
                decoration: BoxDecoration(
                  color: theme.accent1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.cleaning_services, color: theme.accent1),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceTitle,
                      style: theme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      serviceSubtitle,
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _InfoRow(icon: Icons.calendar_today, label: 'Date', value: slotDay),
          SizedBox(height: 8.h),
          _InfoRow(icon: Icons.access_time, label: 'Time', value: slotTime),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: theme.accent1),
              ),
              child: Center(
                child: Text(
                  'Edit Service & Time',
                  style: theme.bodyMedium.copyWith(
                    color: theme.accent1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18.r, color: theme.accent1),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: theme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: theme.bodyMedium.copyWith(color: theme.secondaryText),
          ),
      ],
    );
  }
}
