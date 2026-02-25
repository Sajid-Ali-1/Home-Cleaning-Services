import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class AvailabilityQuickActionsV2 extends StatelessWidget {
  const AvailabilityQuickActionsV2({
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Expanded(
        //   child: _ActionButton(
        //     icon: Icons.content_copy,
        //     label: 'Copy Weekdays',
        //     tooltip: 'Copy Monday hours to all weekdays',
        //     onTap: onCopyWeekdays,
        //   ),
        // ),
        // SizedBox(width: 8.w),
        // Expanded(
        //   child: _ActionButton(
        //     icon: Icons.weekend,
        //     label: 'Copy Weekend',
        //     tooltip: 'Copy Saturday hours to weekend',
        //     onTap: onCopyWeekend,
        //   ),
        // ),
        // SizedBox(width: 8.w),
        _ActionButton(
          icon: Icons.restart_alt,
          label: 'Reset',
          tooltip: 'Reset to default hours (8 AM - 6 PM)',
          onTap: onReset,
        ),
        SizedBox(width: 20.w),
        _ActionButton(
          icon: Icons.delete_sweep,
          label: 'Clear All',
          tooltip: 'Mark all days as unavailable',
          onTap: onClear,
          color: AppTheme.of(context).error,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,

        child: Icon(icon, color: color ?? theme.accent1, size: 20.sp),
      ),
    );
  }
}
