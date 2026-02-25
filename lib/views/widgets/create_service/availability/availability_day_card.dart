import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class AvailabilityDayCard extends StatelessWidget {
  const AvailabilityDayCard({
    super.key,
    required this.availability,
    required this.isToday,
    required this.onToggle,
    required this.onStartTap,
    required this.onEndTap,
  });

  final DailyAvailability availability;
  final bool isToday;
  final ValueChanged<bool> onToggle;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isToday ? theme.accent1 : theme.borderColor,
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                SizedBox(width: 8.w),
                _TodayChip(theme: theme),
              ],
              const Spacer(),
              Switch.adaptive(
                value: availability.isEnabled,
                activeColor: theme.accent1,
                onChanged: onToggle,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (!availability.isEnabled)
            _ClosedLabel(theme: theme)
          else
            _TimeRangeRow(
              theme: theme,
              availability: availability,
              onStartTap: onStartTap,
              onEndTap: onEndTap,
            ),
        ],
      ),
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  const _TimeRangeRow({
    required this.theme,
    required this.availability,
    required this.onStartTap,
    required this.onEndTap,
  });

  final AppTheme theme;
  final DailyAvailability availability;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            label: 'Start',
            value: _formatTime(availability.startTime),
            onTap: onStartTap,
            theme: theme,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _TimeButton(
            label: 'End',
            value: _formatTime(availability.endTime),
            onTap: onEndTap,
            theme: theme,
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

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.textFieldColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedLabel extends StatelessWidget {
  const _ClosedLabel({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.textFieldColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.do_not_disturb_on, color: theme.secondaryText, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            'Unavailable',
            style: theme.bodyMedium.copyWith(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.accent1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'Today',
        style: theme.bodySmall.copyWith(
          color: theme.accent1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

