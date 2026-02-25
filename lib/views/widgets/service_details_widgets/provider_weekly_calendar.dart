import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ProviderWeeklyCalendar extends StatelessWidget {
  const ProviderWeeklyCalendar({super.key, required this.days});

  final List<DailyAvailability> days;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final orderedDays = List<DailyAvailability>.from(days)
      ..sort((a, b) => a.day.index.compareTo(b.day.index));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability',
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),
            // Days list
            ...orderedDays.map(
              (availability) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _DayRow(availability: availability),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.availability});

  final DailyAvailability availability;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isEnabled = availability.isEnabled && availability.hasValidRange();
    final start = availability.startTime;
    final end = availability.endTime;

    return Row(
      children: [
        // Day name
        SizedBox(
          width: 70.w,
          child: Text(
            availability.day.shortLabel,
            style: theme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Time range
        Expanded(
          child: Text(
            isEnabled
                ? '${_formatTime(start)} - ${_formatTime(end)}'
                : 'Closed',
            style: theme.bodyMedium.copyWith(
              color: isEnabled ? theme.primaryText : theme.secondaryText,
              fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
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
