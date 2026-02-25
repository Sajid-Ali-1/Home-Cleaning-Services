import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class AvailabilitySummaryTile extends StatelessWidget {
  const AvailabilitySummaryTile({
    super.key,
    required this.availability,
    required this.isToday,
  });

  final DailyAvailability availability;
  final bool isToday;

  bool get isOpen => availability.isEnabled && availability.hasValidRange();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isToday ? theme.accent1 : theme.borderColor,
          width: isToday ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      availability.day.label,
                      style: theme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    if (isToday) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: theme.accent1,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  isOpen ? _formatRange(availability) : 'Not accepting bookings',
                  style: theme.bodyMedium.copyWith(
                    color: isOpen ? theme.primaryText : theme.secondaryText,
                    fontWeight: isOpen ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isOpen ? Icons.schedule : Icons.do_not_disturb,
            color: isOpen ? theme.accent1 : theme.secondaryText,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  String _formatRange(DailyAvailability day) {
    return '${_formatTime(day.startTime)} - ${_formatTime(day.endTime)}';
  }

  String _formatTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return value;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    final minuteLabel = minute.toString().padLeft(2, '0');
    return '$hour:$minuteLabel $period';
  }
}

