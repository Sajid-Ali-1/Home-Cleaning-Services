import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/nav_pages/nav_page.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).accent1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    size: 100.sp,
                    color: AppTheme.of(context).accent1,
                  ),
                ),
                SizedBox(height: 32.h),

                // Success Title
                Text(
                  'Account Verified!',
                  style: AppTheme.of(context).displayMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // Success Message
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
                            Icons.check_circle,
                            color: AppTheme.of(context).accent1,
                            size: 28.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Your account has been verified successfully',
                              style: AppTheme.of(context).headlineSmall
                                  .copyWith(
                                    color: AppTheme.of(context).accent1,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Congratulations! Your account has been verified by our admin team. You can now create and manage services to reach more customers.',
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
                      _buildFeatureItem(
                        context,
                        Icons.add_circle_outline,
                        'Create Services',
                        'Add cleaning or landscaping services',
                      ),
                      SizedBox(height: 8.h),
                      _buildFeatureItem(
                        context,
                        Icons.edit_outlined,
                        'Manage Services',
                        'Edit and update your service listings',
                      ),
                      SizedBox(height: 8.h),
                      _buildFeatureItem(
                        context,
                        Icons.people_outline,
                        'Reach Customers',
                        'Connect with customers looking for your services',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Continue Button
                CustomButton(
                  buttonText: 'Continue',
                  onTap: () {
                    Get.offAll(() => const NavPage());
                  },
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.of(context).accent1, size: 24.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.of(context).bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.of(context).primaryText,
                ),
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
