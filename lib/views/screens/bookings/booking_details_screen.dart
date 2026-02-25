import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/services/service_db_services.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/chat/chat_screen.dart';
import 'package:home_cleaning_app/views/screens/services/service_details_screen.dart';
import 'package:home_cleaning_app/views/screens/bookings/completion_qr_screen.dart';
import 'package:home_cleaning_app/views/screens/bookings/scan_completion_qr_screen.dart';
import 'package:home_cleaning_app/services/qr_code_service.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.isProviderView,
  });

  final BookingModel booking;
  final bool isProviderView;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final start = booking.startTime.toDate();
    final dateLabel = DateFormat('EEEE, MMMM d, y').format(start);
    final timeLabel = DateFormat('h:mm a').format(start);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        iconTheme: IconThemeData(color: theme.primaryText),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Booking Details',
          style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Title & Status
              _SectionCard(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.serviceTitle,
                          style: theme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _StatusChip(status: booking.status),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Date & Time
              _SectionCard(
                title: 'Date & Time',
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: dateLabel,
                  ),
                  SizedBox(height: 12.h),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: timeLabel,
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Booking Summary with Selections
              _SectionCard(
                title: 'Booking Summary',
                children: [
                  // Show all selected items with quantity and price
                  if (booking.selections.isNotEmpty) ...[
                    ...booking.selections.map((selection) {
                      final name = selection['name'] as String? ?? 'Service';
                      final quantity = selection['quantity'] as num? ?? 0;
                      // Use 'unitPrice' field (as stored in ConfirmBookingController)
                      final unitPrice = selection['unitPrice'] as num? ?? 0.0;
                      // Use stored 'total' if available, otherwise calculate
                      final itemTotal =
                          (selection['total'] as num?)?.toDouble() ??
                          (unitPrice * quantity);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: theme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${itemTotal.toStringAsFixed(2)}',
                                  style: theme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.accent1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  'Quantity: ',
                                  style: theme.bodySmall.copyWith(
                                    color: theme.secondaryText,
                                  ),
                                ),
                                Text(
                                  '${quantity.toInt()}',
                                  style: theme.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Text(
                                  'Unit Price: ',
                                  style: theme.bodySmall.copyWith(
                                    color: theme.secondaryText,
                                  ),
                                ),
                                Text(
                                  '\$${unitPrice.toStringAsFixed(2)}',
                                  style: theme.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    Divider(height: 24.h, color: theme.dividerColor),
                  ],
                  // Pricing breakdown
                  _InfoRow(
                    icon: Icons.receipt,
                    label: 'Subtotal',
                    value: '\$${booking.subtotal.toStringAsFixed(2)}',
                  ),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    icon: Icons.percent,
                    label: 'Tax & Fees',
                    value: '\$${booking.tax.toStringAsFixed(2)}',
                  ),
                  Divider(height: 24.h, color: theme.dividerColor),
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Total',
                    value: '\$${booking.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  if (booking.paymentMethodLabel != null) ...[
                    SizedBox(height: 12.h),
                    _InfoRow(
                      icon: Icons.payment,
                      label: 'Payment Method',
                      value: booking.paymentMethodLabel!,
                    ),
                  ],
                ],
              ),

              // Notes
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'Notes',
                  children: [Text(booking.notes!, style: theme.bodyMedium)],
                ),
              ],

              // Refund Information
              if (booking.refundStatus != null) ...[
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'Refund Information',
                  children: [
                    _InfoRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: booking.refundStatus!.name.toUpperCase(),
                    ),
                    if (booking.refundAmount != null) ...[
                      SizedBox(height: 8.h),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: 'Refund Amount',
                        value: '\$${booking.refundAmount!.toStringAsFixed(2)}',
                      ),
                    ],
                    if (booking.refundReason != null) ...[
                      SizedBox(height: 8.h),
                      _InfoRow(
                        icon: Icons.description,
                        label: 'Reason',
                        value: booking.refundReason!,
                      ),
                    ],
                    if (booking.refundProcessedAt != null) ...[
                      SizedBox(height: 8.h),
                      _InfoRow(
                        icon: Icons.schedule,
                        label: 'Processed At',
                        value: DateFormat(
                          'MMM d, y h:mm a',
                        ).format(booking.refundProcessedAt!.toDate()),
                      ),
                    ],
                  ],
                ),
              ],

              // Timestamps
              SizedBox(height: 16.h),
              _SectionCard(
                title: 'Booking Information',
                children: [
                  if (booking.createdAt != null)
                    _InfoRow(
                      icon: Icons.add_circle_outline,
                      label: 'Created',
                      value: DateFormat(
                        'MMM d, y h:mm a',
                      ).format(booking.createdAt!.toDate()),
                    ),
                  if (booking.updatedAt != null) ...[
                    if (booking.createdAt != null) SizedBox(height: 8.h),
                    _InfoRow(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: DateFormat(
                        'MMM d, y h:mm a',
                      ).format(booking.updatedAt!.toDate()),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 24.h),

              // QR Code Actions
              if (booking.status == BookingStatus.accepted) ...[
                if (!isProviderView)
                  // Customer: Show QR Code
                  _ActionButton(
                    label: 'Show Completion QR Code',
                    icon: Icons.qr_code,
                    onTap: () {
                      if (QrCodeService.canGenerateQrCode(booking.startTime.toDate())) {
                        Get.to(() => CompletionQrScreen(booking: booking));
                      } else {
                        Get.snackbar(
                          'Not Available',
                          'QR code will be available 15 minutes before the booking start time.',
                        );
                      }
                    },
                  )
                else
                  // Provider: Scan QR Code
                  _ActionButton(
                    label: 'Scan QR to Complete',
                    icon: Icons.qr_code_scanner,
                    onTap: () {
                      Get.to(() => ScanCompletionQrScreen(booking: booking));
                    },
                  ),
                SizedBox(height: 12.h),
              ],

              // Action Buttons
              if (booking.status != BookingStatus.canceled &&
                  booking.status != BookingStatus.rejected)
                _ActionButton(
                  label: 'Open Chat',
                  icon: Icons.chat,
                  onTap: () {
                    if (booking.bookingId != null) {
                      Get.to(
                        () => ChatScreen(
                          booking: booking,
                          isProviderView: isProviderView,
                        ),
                      );
                    }
                  },
                ),

              SizedBox(height: 12.h),

              // View Service Button
              _ActionButton(
                label: 'View Service',
                icon: Icons.info_outline,
                backgroundColor: theme.secondaryBackground,
                textColor: theme.accent1,
                onTap: () async {
                  if (booking.serviceId.isEmpty) {
                    Get.snackbar('Error', 'Service information not available');
                    return;
                  }

                  try {
                    // Show loading
                    Get.dialog(
                      Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    // Fetch service details
                    final service = await ServiceDbServices.getServiceById(
                      booking.serviceId,
                    );

                    Get.back(); // Close loading dialog

                    if (service != null) {
                      Get.to(() => ServiceDetailsScreen(service: service));
                    } else {
                      Get.snackbar('Error', 'Service not found');
                    }
                  } catch (e) {
                    Get.back(); // Close loading dialog if open
                    Get.snackbar(
                      'Error',
                      'Failed to load service: ${e.toString()}',
                    );
                  }
                },
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
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
          if (title != null) ...[
            Text(
              title!,
              style: theme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.accent1,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: isTotal ? theme.accent1 : theme.secondaryText,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: theme.bodySmall.copyWith(color: theme.secondaryText),
          ),
        ),
        Text(
          value,
          style: theme.bodyMedium.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? theme.accent1 : theme.primaryText,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = _resolveColor(theme);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: theme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _resolveColor(AppTheme theme) {
    switch (status) {
      case BookingStatus.accepted:
        return theme.success;
      case BookingStatus.completed:
        return theme.accent1;
      case BookingStatus.rejected:
        return theme.error;
      case BookingStatus.canceled:
        return theme.secondaryText;
      case BookingStatus.requested:
        return theme.warning;
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bgColor = backgroundColor ?? theme.accent1;
    final txtColor = textColor ?? Colors.white;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: backgroundColor != null
                ? BorderSide(color: theme.dividerColor)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: txtColor),
            SizedBox(width: 8.w),
            Text(
              label,
              style: theme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
