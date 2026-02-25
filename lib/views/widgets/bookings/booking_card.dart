import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/bookings/booking_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.isProviderView,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.onChat,
  });

  final BookingModel booking;
  final bool isProviderView;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onChat;

  bool get _canChat =>
      booking.status != BookingStatus.canceled &&
      booking.status != BookingStatus.rejected;

  bool get _showAcceptReject =>
      isProviderView && booking.status == BookingStatus.requested;

  bool get _showCancel =>
      !isProviderView && booking.status == BookingStatus.requested;

  Future<void> _openMap(double latitude, double longitude) async {
    // Try to open in Google Maps first, fallback to Apple Maps on iOS
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$latitude,$longitude',
    );

    try {
      // Try Google Maps first
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        // Fallback to Apple Maps
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open maps application');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open maps: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final start = booking.startTime.toDate();
    final dateLabel = DateFormat('EEEE, MMM d').format(start);
    final timeLabel = DateFormat('h:mm a').format(start);

    return GestureDetector(
      onTap: () {
        // Navigate to booking details screen
        Get.to(
          () => BookingDetailsScreen(
            booking: booking,
            isProviderView: isProviderView,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 8.h),
            Text(
              dateLabel,
              style: theme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              timeLabel,
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 18.sp,
                  color: theme.secondaryText,
                ),
                SizedBox(width: 6.w),
                Text(
                  '\$${booking.total.toStringAsFixed(2)} paid',
                  style: theme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.person, size: 18.sp, color: theme.secondaryText),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    isProviderView
                        ? 'Customer: ${booking.customerName ?? 'Client'}'
                        : 'Provider: ${booking.providerName ?? 'Service Pro'}',
                    style: theme.bodySmall.copyWith(color: theme.secondaryText),
                  ),
                ),
              ],
            ),
            // Show customer location for provider view
            if (isProviderView &&
                booking.customerAddress != null &&
                booking.customerAddress!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18.sp,
                    color: theme.secondaryText,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      booking.customerAddress!,
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Show map button for provider view when location is available
                  GestureDetector(
                    onTap: () => _openMap(
                      booking.customerLatitude!,
                      booking.customerLongitude!,
                    ),

                    child: Icon(Icons.map, size: 16.sp, color: theme.accent1),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                if (_showAcceptReject) ...[
                  _ActionButton(
                    label: 'Reject',
                    onTap: () {
                      if (onReject != null) onReject!();
                    },
                    backgroundColor: theme.error.withOpacity(0.12),
                    textColor: theme.error,
                  ),
                  _ActionButton(
                    label: 'Accept',
                    onTap: () {
                      if (onAccept != null) onAccept!();
                    },
                    backgroundColor: theme.accent1,
                    textColor: Colors.white,
                  ),
                ],
                if (_showCancel)
                  _ActionButton(
                    label: 'Cancel',
                    onTap: () {
                      if (onCancel != null) onCancel!();
                    },
                    backgroundColor: theme.textFieldColor,
                    textColor: theme.primaryText,
                  ),
                if (_canChat)
                  _ActionButton(
                    label: 'Chat',
                    onTap: () {
                      if (onChat != null) onChat!();
                    },
                    backgroundColor: theme.textFieldColor,
                    textColor: theme.accent1,
                    prefix: Icon(Icons.chat, size: 16.sp, color: theme.accent1),
                  ),
              ],
            ),
          ],
        ),
      ),
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
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.prefix,
  });

  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color textColor;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix != null) ...[prefix!, SizedBox(width: 6.w)],
            Text(
              label,
              style: AppTheme.of(context).bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
