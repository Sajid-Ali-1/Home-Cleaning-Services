import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class AvailabilityQuickActions extends StatelessWidget {
  const AvailabilityQuickActions({
    super.key,
    required this.onCopyWeekdays,
    required this.onCopyWeekend,
    required this.onReset,
    required this.onClear,
  });

  final VoidCallback onCopyWeekdays;
  final VoidCallback onCopyWeekend;
  final VoidCallback onReset;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.textFieldColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          _AvailabilityActionIcon(
            icon: Icons.content_copy,
            label: 'Copy weekdays',
            tooltip: 'Double tap to copy Monday hours to Mon-Fri',
            onTap: onCopyWeekdays,
          ),
          _AvailabilityActionIcon(
            icon: Icons.weekend,
            label: 'Mirror weekend',
            tooltip: 'Double tap to copy Saturday hours to Sat-Sun',
            onTap: onCopyWeekend,
          ),
          _AvailabilityActionIcon(
            icon: Icons.restart_alt,
            label: 'Reset',
            tooltip: 'Double tap to load the default 8 AM - 6 PM template',
            onTap: onReset,
          ),
          _AvailabilityActionIcon(
            icon: Icons.delete_sweep,
            label: 'Clear',
            tooltip: 'Double tap to mark every day as unavailable',
            onTap: onClear,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityActionIcon extends StatelessWidget {
  const _AvailabilityActionIcon({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onTap,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(icon, color: theme.primaryText, size: 20.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: theme.bodySmall.copyWith(
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

