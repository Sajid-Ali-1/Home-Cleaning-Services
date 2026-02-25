import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class WeeklyCalendarView extends StatelessWidget {
  const WeeklyCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();
    final theme = AppTheme.of(context);
    final today = Weekday.values[DateTime.now().weekday - 1];

    return Obx(() {
      final days = controller.weeklyAvailability
        ..sort((a, b) => a.day.index.compareTo(b.day.index));
      return Container(
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
                'Weekly Schedule',
                style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              // Days list
              ...days.map((availability) {
                final isToday = availability.day == today;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _DayRow(
                    availability: availability,
                    isToday: isToday,
                    onToggle: (value) => controller.toggleDayAvailability(
                      availability.day,
                      value,
                    ),
                    onTimeTap: () =>
                        _showTimePickerSheet(context, controller, availability),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  void _showTimePickerSheet(
    BuildContext context,
    CreateServiceFormController controller,
    DailyAvailability availability,
  ) {
    if (!availability.isEnabled) {
      Get.snackbar(
        'Day Disabled',
        'Enable the day first to set availability hours.',
      );
      return;
    }

    _showInlinePickers(context, controller, availability);
  }

  Future<void> _showInlinePickers(
    BuildContext context,
    CreateServiceFormController controller,
    DailyAvailability availability,
  ) async {
    final startInitial = availability.startAsTimeOfDay;
    final endInitial = availability.endAsTimeOfDay;

    final startResult = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dial,
      initialTime: startInitial,
      helpText: 'Select start time',
    );
    if (startResult == null) return;

    final endResult = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: endInitial,
      helpText: 'Select end time',
    );
    if (endResult == null) return;

    final startMinutes = startResult.hour * 60 + startResult.minute;
    final endMinutes = endResult.hour * 60 + endResult.minute;
    if (endMinutes <= startMinutes) {
      Get.snackbar('Invalid range', 'End time must be after start time.');
      return;
    }

    controller.updateDayTime(
      availability.day,
      start: startResult,
      end: endResult,
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.availability,
    required this.isToday,
    required this.onToggle,
    required this.onTimeTap,
  });

  final DailyAvailability availability;
  final bool isToday;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isEnabled = availability.isEnabled && availability.hasValidRange();

    return Row(
      children: [
        // Day name
        SizedBox(
          width: 70.w,
          child: Text(
            availability.day.shortLabel,
            style: theme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isToday ? theme.accent1 : theme.primaryText,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Toggle switch
        Switch.adaptive(
          value: availability.isEnabled,
          activeColor: theme.accent1,
          onChanged: onToggle,
        ),
        SizedBox(width: 12.w),
        // Time range - tappable
        Expanded(
          child: GestureDetector(
            onTap: onTimeTap,
            child: Text(
              isEnabled
                  ? '${_formatTime(availability.startTime)} - ${_formatTime(availability.endTime)}'
                  : 'Closed',
              style: theme.bodyMedium.copyWith(
                color: isEnabled ? theme.primaryText : theme.secondaryText,
                fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w400,
              ),
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

class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({required this.availability, required this.onSave});

  final DailyAvailability availability;
  final Function(TimeOfDay, TimeOfDay) onSave;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    startTime = widget.availability.startAsTimeOfDay;
    endTime = widget.availability.endAsTimeOfDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.borderColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Availability for ${widget.availability.day.label}',
                  style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 24.h),
                // Start time
                _TimeSelector(
                  label: 'Start Time',
                  time: startTime,
                  onTimeChanged: (time) {
                    if (time.hour * 60 + time.minute <
                        endTime.hour * 60 + endTime.minute) {
                      setState(() => startTime = time);
                    } else {
                      Get.snackbar(
                        'Invalid Time',
                        'Start time must be before end time.',
                      );
                    }
                  },
                ),
                SizedBox(height: 20.h),
                // End time
                _TimeSelector(
                  label: 'End Time',
                  time: endTime,
                  onTimeChanged: (time) {
                    if (time.hour * 60 + time.minute >
                        startTime.hour * 60 + startTime.minute) {
                      setState(() => endTime = time);
                    } else {
                      Get.snackbar(
                        'Invalid Time',
                        'End time must be after start time.',
                      );
                    }
                  },
                ),
                SizedBox(height: 24.h),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: theme.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: theme.bodyMedium.copyWith(
                            color: theme.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onSave(startTime, endTime);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent1,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save',
                          style: theme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTimeChanged,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.secondaryText,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final result = await showTimePicker(
              context: context,
              initialEntryMode: TimePickerEntryMode.dial,
              initialTime: time,
              helpText: label,
            );
            if (result != null) {
              onTimeChanged(result);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: theme.textFieldColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                Icon(Icons.access_time, color: theme.accent1, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
