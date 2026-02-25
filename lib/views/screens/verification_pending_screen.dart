import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

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
          'Verification Pending',
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
                  color: AppTheme.of(context).accent1.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 80.sp,
                  color: AppTheme.of(context).accent1,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Account Verification Pending',
                style: AppTheme.of(context).displayMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).accent1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppTheme.of(context).accent1,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.of(context).accent1,
                          size: 28.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Your account is pending verification',
                            style: AppTheme.of(context).headlineSmall.copyWith(
                              color: AppTheme.of(context).accent1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Before you can create and manage services, your account needs to be verified by our admin team. This process typically takes 24-48 hours.',
                      style: AppTheme.of(context).bodyMedium.copyWith(
                        color: AppTheme.of(context).primaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16.h),
                    Divider(
                      color: AppTheme.of(context).accent1.withOpacity(0.3),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.pending_outlined,
                          color: AppTheme.of(context).accent1,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Creating services requires verification',
                            style: AppTheme.of(context).bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'What happens next?',
                style: AppTheme.of(context).headlineSmall,
              ),
              SizedBox(height: 16.h),
              _buildStepItem(
                context,
                '1',
                'Admin reviews your profile',
                'We check your account details and credentials',
              ),
              SizedBox(height: 12.h),
              _buildStepItem(
                context,
                '2',
                'Verification email sent',
                'You\'ll receive a notification once verified',
              ),
              SizedBox(height: 12.h),
              _buildStepItem(
                context,
                '3',
                'Start creating services',
                'Once verified, you can add and manage services',
              ),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: () async {
                  // Refresh user data to check if verified
                  await authController.refreshUserData();
                },
                icon: Icon(Icons.refresh, color: AppTheme.of(context).accent1),
                label: Text(
                  'Check Verification Status',
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

  Widget _buildStepItem(
    BuildContext context,
    String stepNumber,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppTheme.of(context).accent1,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.of(
                  context,
                ).bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: AppTheme.of(
                  context,
                ).bodySmall.copyWith(color: AppTheme.of(context).secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
