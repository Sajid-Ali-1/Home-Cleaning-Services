import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/confirm_booking_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/booking/booking_details_card.dart';
import 'package:home_cleaning_app/views/widgets/booking/booking_notes_field.dart';
import 'package:home_cleaning_app/views/widgets/booking/booking_summary_card.dart';
import 'package:home_cleaning_app/views/widgets/booking/payment_method_selector.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({super.key});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  late final ConfirmBookingController controller;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ConfirmBookingController>();
    notesController = TextEditingController(text: controller.notes.value);
    notesController.addListener(
      () => controller.updateNotes(notesController.text),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    if (Get.isRegistered<ConfirmBookingController>()) {
      Get.delete<ConfirmBookingController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Confirm Booking',
          style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: theme.primaryText),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingDetailsCard(
              serviceTitle: controller.service.title ?? 'Service',
              serviceSubtitle:
                  controller.service.location ?? 'No location provided',
              slotDay: controller.formattedDay,
              slotTime: controller.formattedTime,
              onEditTap: Get.back,
            ),
            SizedBox(height: 16.h),
            BookingSummaryCard(
              selections: controller.selections,
              subtotal: controller.subtotal,
              tax: controller.tax,
              total: controller.total,
            ),
            SizedBox(height: 16.h),
            Obx(
              () => PaymentMethodSelector(
                selectedMethod: controller.selectedMethod.value,
                onChanged: controller.pickPaymentMethod,
              ),
            ),
            SizedBox(height: 16.h),
            BookingNotesField(controller: notesController),
            SizedBox(height: 4.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        // minimum: EdgeInsets.all(16.w),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.of(context).shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustomButton(
                      buttonText: 'Confirm Booking',
                      onTap: controller.isProcessing.value
                          ? null
                          : () => controller.confirmBooking(context),
                      isLoading: controller.isProcessing.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
