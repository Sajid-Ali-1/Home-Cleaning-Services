import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/booking_completion_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CompletionQrScreen extends StatelessWidget {
  const CompletionQrScreen({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    Get.put(BookingCompletionController(booking: booking));

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        iconTheme: IconThemeData(color: theme.primaryText),
        elevation: 0,
        title: Text(
          'Completion QR Code',
          style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<BookingCompletionController>(
          builder: (controller) {
            final startTime = booking.startTime.toDate();
            final now = DateTime.now();
            final fifteenMinutesBefore = startTime.subtract(const Duration(minutes: 15));
            final canShow = now.isAfter(fifteenMinutesBefore) || now.isAtSameMomentAs(fifteenMinutesBefore);
            final timeUntilStart = fifteenMinutesBefore.difference(now);

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Service Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceTitle,
                          style: theme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (booking.providerName != null)
                          Text(
                            'Provider: ${booking.providerName}',
                            style: theme.bodyMedium.copyWith(
                              color: theme.secondaryText,
                            ),
                          ),
                        SizedBox(height: 8.h),
                        Text(
                          'Date: ${DateFormat('EEEE, MMMM d, y').format(startTime)}',
                          style: theme.bodySmall.copyWith(
                            color: theme.secondaryText,
                          ),
                        ),
                        Text(
                          'Time: ${DateFormat('h:mm a').format(startTime)}',
                          style: theme.bodySmall.copyWith(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Status Indicator
                  if (!canShow)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: theme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, color: theme.warning, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'QR code will be available in ${_formatDuration(timeUntilStart)}',
                            style: theme.bodyMedium.copyWith(
                              color: theme.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: theme.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: theme.success, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'QR Code Ready',
                            style: theme.bodyMedium.copyWith(
                              color: theme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 32.h),

                  // QR Code Display
                  if (canShow) ...[
                    if (controller.qrCodeData.value.isEmpty)
                      Obx(
                        () => controller.isGeneratingQr.value
                            ? Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Generating QR code...',
                                    style: theme.bodyMedium.copyWith(
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: controller.generateQrCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.accent1,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 16.h,
                                  ),
                                ),
                                child: Text(
                                  'Generate QR Code',
                                  style: theme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      )
                    else
                      Obx(
                        () => Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: QrImageView(
                                data: controller.qrCodeData.value,
                                size: 300.w,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: theme.accent1,
                                    size: 24.sp,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Show this QR code to your service provider when the job is complete',
                                    textAlign: TextAlign.center,
                                    style: theme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextButton.icon(
                              onPressed: controller.generateQrCode,
                              icon: Icon(Icons.refresh, size: 20.sp),
                              label: Text('Refresh QR Code'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.accent1,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Error Message
                    if (controller.errorMessage.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: theme.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: theme.error, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: theme.bodySmall.copyWith(color: theme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}
