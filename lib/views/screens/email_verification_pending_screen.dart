import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/auth/login_screen.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';

class EmailVerificationPendingScreen extends StatelessWidget {
  const EmailVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Verify Your Email',
          style: AppTheme.of(context).displaySmall,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(32.r, 10.r, 32.r, 32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 80.sp,
                  color: AppTheme.of(context).primary,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Verify Your Email Address',
                style: AppTheme.of(context).displayMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppTheme.of(context).primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.of(context).primary,
                          size: 28.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Check your email inbox',
                            style: AppTheme.of(context).headlineSmall.copyWith(
                              color: AppTheme.of(context).primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'We\'ve sent a verification email to your email address. Please check your inbox and click on the verification link to activate your account.',
                      style: AppTheme.of(context).bodyMedium.copyWith(
                        color: AppTheme.of(context).primaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16.h),
                    Divider(
                      color: AppTheme.of(context).primary.withOpacity(0.3),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.of(context).secondaryText,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Check your inbox and spam folder',
                            style: AppTheme.of(context).bodySmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.of(context).secondaryText,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Click the verification link in the email',
                            style: AppTheme.of(context).bodySmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.of(context).secondaryText,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Return to the app and continue',
                            style: AppTheme.of(context).bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              CustomButton(
                buttonText: 'I\'ve Verified My Email',
                onTap: () async {
                  // Check if email is verified
                  await authController.checkEmailVerification();
                },
                isExpanded: true,
              ),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: () async {
                  try {
                    await authController.resendEmailVerification();
                    Get.snackbar(
                      'Success',
                      'Verification email sent! Please check your inbox.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.of(context).success,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.of(context).error,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: Icon(Icons.refresh, color: AppTheme.of(context).accent1),
                label: Text(
                  'Resend Verification Email',
                  style: AppTheme.of(
                    context,
                  ).bodySmall.copyWith(color: AppTheme.of(context).accent1),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: () async {
                  // Sign out and go back to login
                  await authController.signOut();
                  Get.offAll(() => LoginScreen());
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.of(context).accent1,
                ),
                label: Text(
                  'Back to Login',
                  style: AppTheme.of(
                    context,
                  ).bodySmall.copyWith(color: AppTheme.of(context).accent1),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
