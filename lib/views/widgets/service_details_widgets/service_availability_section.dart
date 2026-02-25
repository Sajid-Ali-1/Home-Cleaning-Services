import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/customer_availability_chips.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/provider_weekly_calendar.dart';

class ServiceAvailabilitySection extends StatelessWidget {
  const ServiceAvailabilitySection({
    super.key,
    required this.isCustomerView,
    required this.isOwnerView,
  });

  final bool isCustomerView;
  final bool isOwnerView;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();
    final theme = AppTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            isOwnerView
                ? 'Customers will see these active hours before requesting a booking.'
                : 'Choose any time within the provider\'s working hours.',
            style: theme.bodyMedium.copyWith(color: theme.secondaryText),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (!controller.hasAvailability) {
              return _EmptyAvailabilityCard(isOwnerView: isOwnerView);
            }
            if (isOwnerView) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProviderWeeklyCalendar(days: controller.availabilityDays),
                  SizedBox(height: 16.h),
                  const _OwnerHint(),
                ],
              );
            }

            final groups = controller.availabilityDayGroups;
            if (groups.isEmpty) {
              return _EmptyAvailabilityCard(isOwnerView: false);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerAvailabilityPicker(
                  dayGroups: groups,
                  selectedDateKey: controller.selectedDate.value,
                  selectedTimeKey: controller.selectedTime.value,
                  onSlotSelected: controller.selectAvailabilitySlot,
                ),
                SizedBox(height: 16.h),
                const _CustomerHint(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyAvailabilityCard extends StatelessWidget {
  const _EmptyAvailabilityCard({required this.isOwnerView});

  final bool isOwnerView;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final title = isOwnerView
        ? 'You haven’t set your availability yet.'
        : 'Availability not shared yet.';
    final subtitle = isOwnerView
        ? 'Add your weekly hours from the edit service screen so customers can book exact slots.'
        : 'The provider is updating their schedule. Please check again soon.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.textFieldColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hourglass_empty, color: theme.secondaryText, size: 26.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerHint extends StatelessWidget {
  const _CustomerHint();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.accent1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.accent1, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Your booking request should fall inside these hours. The provider will accept or reject your request. Unconfirmed requests are auto-canceled after 24 hours or if the time has passed. Your payment will be refunded if the request is rejected or auto-canceled.',
              style: theme.bodySmall.copyWith(
                color: theme.primaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerHint extends StatelessWidget {
  const _OwnerHint();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      // decoration: BoxDecoration(
      //   color: theme.textFieldColor,
      //   borderRadius: BorderRadius.circular(14.r),
      //   border: Border.all(color: theme.borderColor),
      // ),
      decoration: BoxDecoration(
        color: theme.accent1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.accent1.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates, color: theme.accent1, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Need changes? Edit this service and adjust the Availability step so customers always get up-to-date hours.',
              // style: theme.bodySmall.copyWith(
              //   color: theme.secondaryText,
              //   height: 1.4,
              // ),
              style: theme.bodySmall.copyWith(
                color: theme.primaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
