import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/services/stripe_connect_service.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeConnectOnboardingScreen extends StatefulWidget {
  const StripeConnectOnboardingScreen({super.key});

  @override
  State<StripeConnectOnboardingScreen> createState() =>
      _StripeConnectOnboardingScreenState();
}

class _StripeConnectOnboardingScreenState
    extends State<StripeConnectOnboardingScreen> {
  bool _isLoading = false;
  bool _isCheckingStatus = false;
  Map<String, dynamic>? _accountStatus;

  @override
  void initState() {
    super.initState();
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    setState(() => _isCheckingStatus = true);
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.userModel?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final status = await StripeConnectService.getAccountStatus(userId);
      setState(() {
        _accountStatus = status;
        _isCheckingStatus = false;
      });
    } catch (e) {
      setState(() => _isCheckingStatus = false);
      Get.snackbar('Error', 'Failed to check account status: ${e.toString()}');
    }
  }

  Future<void> _createAccount() async {
    setState(() => _isLoading = true);
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.userModel?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final onboardingUrl = await StripeConnectService.createConnectAccount(userId);

      // Open onboarding URL in browser
      final uri = Uri.parse(onboardingUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Get.snackbar(
          'Success',
          'Please complete the onboarding process in the browser. Return here when done.',
        );
        // Refresh status after a delay
        Future.delayed(const Duration(seconds: 3), () {
          _checkAccountStatus();
        });
      } else {
        Get.snackbar('Error', 'Could not open onboarding URL');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        iconTheme: IconThemeData(color: theme.primaryText),
        elevation: 0,
        title: Text(
          'Payment Setup',
          style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
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
                        Icon(
                          Icons.account_balance_wallet,
                          color: theme.accent1,
                          size: 32.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Stripe Connect',
                            style: theme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Set up your payment account to receive payouts from completed bookings.',
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Status Section
              if (_isCheckingStatus)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.h),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Checking account status...',
                          style: theme.bodyMedium.copyWith(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_accountStatus != null) ...[
                // Account Status Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: _accountStatus!['onboardingComplete'] == true
                        ? theme.success.withOpacity(0.1)
                        : theme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: _accountStatus!['onboardingComplete'] == true
                          ? theme.success
                          : theme.warning,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _accountStatus!['onboardingComplete'] == true
                                ? Icons.check_circle
                                : Icons.pending,
                            color: _accountStatus!['onboardingComplete'] == true
                                ? theme.success
                                : theme.warning,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _accountStatus!['onboardingComplete'] == true
                                  ? 'Account Setup Complete'
                                  : 'Account Setup Required',
                              style: theme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _accountStatus!['onboardingComplete'] == true
                                    ? theme.success
                                    : theme.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      if (_accountStatus!['hasAccount'] == true) ...[
                        _StatusRow(
                          label: 'Account ID',
                          value: _accountStatus!['accountId'] as String? ?? 'N/A',
                        ),
                        SizedBox(height: 8.h),
                        _StatusRow(
                          label: 'Charges Enabled',
                          value: _accountStatus!['chargesEnabled'] == true
                              ? 'Yes'
                              : 'No',
                        ),
                        SizedBox(height: 8.h),
                        _StatusRow(
                          label: 'Payouts Enabled',
                          value: _accountStatus!['payoutsEnabled'] == true
                              ? 'Yes'
                              : 'No',
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Action Button
                if (_accountStatus!['onboardingComplete'] != true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent1,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  _accountStatus!['hasAccount'] == true
                                      ? 'Complete Onboarding'
                                      : 'Set Up Payment Account',
                                  style: theme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.accent1, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Your payment account is set up. You will receive payouts automatically after bookings are completed.',
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 16.h),
                // Refresh Button
                TextButton.icon(
                  onPressed: _checkAccountStatus,
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text('Refresh Status'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.accent1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.bodyMedium.copyWith(
            color: theme.secondaryText,
          ),
        ),
        Text(
          value,
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
