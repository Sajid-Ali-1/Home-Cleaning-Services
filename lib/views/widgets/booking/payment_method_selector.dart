import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:home_cleaning_app/controllers/confirm_booking_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  final BookingPaymentMethod selectedMethod;
  final ValueChanged<BookingPaymentMethod> onChanged;

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  bool _isGooglePayAvailable = false;
  bool _isApplePayAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentMethodAvailability();
  }

  Future<void> _checkPaymentMethodAvailability() async {
    try {
      // Check if platform pay (Google Pay/Apple Pay) is available
      final isPlatformPaySupported = await Stripe.instance
          .isPlatformPaySupported();

      setState(() {
        if (Platform.isAndroid) {
          _isGooglePayAvailable = isPlatformPaySupported;
        } else if (Platform.isIOS) {
          _isApplePayAvailable = isPlatformPaySupported;
        }
      });
    } catch (e) {
      // If check fails, assume not available
      setState(() {
        _isGooglePayAvailable = false;
        _isApplePayAvailable = false;
      });
    }
  }

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
          Text(
            'Payment Method',
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _MethodTile(
            label: 'Credit / Debit Card',
            caption: 'Powered by Stripe (test mode)',
            icon: Icons.credit_card,
            isSelected: widget.selectedMethod == BookingPaymentMethod.card,
            onTap: () => widget.onChanged(BookingPaymentMethod.card),
          ),
          // // Show Google Pay only on Android and if available
          // if (Platform.isAndroid && _isGooglePayAvailable) ...[
          //   SizedBox(height: 12.h),
          //   _MethodTile(
          //     label: 'Google Pay',
          //     caption: 'Fast and secure',
          //     icon: Icons.account_balance_wallet,
          //     isSelected:
          //         widget.selectedMethod == BookingPaymentMethod.googlePay,
          //     onTap: () => widget.onChanged(BookingPaymentMethod.googlePay),
          //   ),
          // ],
          // // Show Apple Pay only on iOS and if available
          // if (Platform.isIOS && _isApplePayAvailable) ...[
          //   SizedBox(height: 12.h),
          //   _MethodTile(
          //     label: 'Apple Pay',
          //     caption: 'Fast and secure',
          //     icon: Icons.apple,
          //     isSelected:
          //         widget.selectedMethod == BookingPaymentMethod.applePay,
          //     onTap: () => widget.onChanged(BookingPaymentMethod.applePay),
          //   ),
          // ],
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.label,
    required this.caption,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? theme.accent1 : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.accent1),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.bodyMedium.copyWith(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    caption,
                    style: theme.bodySmall.copyWith(color: theme.secondaryText),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.accent1 : theme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
