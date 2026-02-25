import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:intl/intl.dart';

class CustomerAvailabilityPicker extends StatelessWidget {
  const CustomerAvailabilityPicker({
    super.key,
    required this.dayGroups,
    required this.selectedDateKey,
    required this.selectedTimeKey,
    required this.onSlotSelected,
  });

  final List<AvailabilityDayGroup> dayGroups;
  final String selectedDateKey;
  final String selectedTimeKey;
  final ValueChanged<AvailabilitySlotView> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    if (dayGroups.isEmpty) {
      return _EmptyState(theme: theme);
    }
    final activeGroup = dayGroups.firstWhere(
      (group) => group.dateKey == selectedDateKey,
      orElse: () => dayGroups.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dayGroups.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final group = dayGroups[index];
              final isSelected = group.dateKey == selectedDateKey;
              return _DayCard(
                group: group,
                isSelected: isSelected,
                onTap: () {
                  if (group.slots.isNotEmpty) {
                    onSlotSelected(group.slots.first);
                  }
                },
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        if (activeGroup.slots.isEmpty)
          _NoSlotsBanner(theme: theme)
        else
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: activeGroup.slots
                .map(
                  (slot) => _TimeChip(
                    label: slot.timeLabel,
                    isSelected: slot.startRaw == selectedTimeKey,
                    onTap: () => onSlotSelected(slot),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  final AvailabilityDayGroup group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final dateLabel = DateFormat('EEE').format(group.date);
    final dayNumber = DateFormat('d').format(group.date);
    final slotsLabel = group.slots.isEmpty
        ? 'No slots'
        : '${group.slots.length} slots';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90.w,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent1 : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? theme.accent1 : theme.dividerColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateLabel.toUpperCase(),
              style: theme.bodySmall.copyWith(
                color: isSelected ? Colors.white : theme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              dayNumber,
              style: theme.bodyLarge.copyWith(
                color: isSelected ? Colors.white : theme.primaryText,
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              slotsLabel,
              style: theme.bodySmall.copyWith(
                color: isSelected ? Colors.white70 : theme.secondaryText,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent1 : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? theme.accent1 : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.bodyMedium.copyWith(
            color: isSelected ? Colors.white : theme.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.textFieldColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.timelapse, color: theme.secondaryText),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'The provider has not shared upcoming slots. Try checking again later.',
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSlotsBanner extends StatelessWidget {
  const _NoSlotsBanner({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: theme.accent1.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.accent1),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'No times on this day. Pick another date to continue.',
              style: theme.bodySmall.copyWith(color: theme.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
