import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/availability/availability_quick_actions_v2.dart';
import 'package:home_cleaning_app/views/widgets/create_service/availability/weekly_calendar_view.dart';

class Step3Availability extends StatelessWidget {
  const Step3Availability({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your weekly availability schedule',
          style: theme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Customers will see these hours when booking. Tap any day to adjust times.',
          style: theme.bodyMedium.copyWith(color: theme.secondaryText),
        ),
        SizedBox(height: 20.h),
        // Quick actions
        AvailabilityQuickActionsV2(
          onCopyWeekdays: () =>
              controller.copyDayToTargets(Weekday.monday, const [
                Weekday.monday,
                Weekday.tuesday,
                Weekday.wednesday,
                Weekday.thursday,
                Weekday.friday,
              ]),
          onCopyWeekend: () => controller.copyDayToTargets(
            Weekday.saturday,
            const [Weekday.saturday, Weekday.sunday],
          ),
          onReset: controller.resetAvailabilityToDefault,
          onClear: controller.clearAvailability,
        ),
        SizedBox(height: 20.h),
        // Weekly calendar view
        const WeeklyCalendarView(),
        SizedBox(height: 16.h),
        // Info card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.accent1.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.accent1.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: theme.accent1, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Toggle days on/off and tap time ranges to adjust. Use quick actions to copy hours across multiple days.',
                  style: theme.bodySmall.copyWith(
                    color: theme.primaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
