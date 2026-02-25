import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/services/create_service_screen.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';

class ServicesEmptyStateProvider extends StatelessWidget {
  const ServicesEmptyStateProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isVerified = authController.userModel?.isVerified ?? false;

    return Center(
      child: SingleChildScrollView(
        // padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            // Large icon with background
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cleaning_services_outlined,
                size: 80.sp,
                color: AppTheme.of(context).accent1,
              ),
            ),
            SizedBox(height: 32.h),
            // Title
            Text(
              'No Services Yet',
              style: AppTheme.of(
                context,
              ).displayMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Description
            Text(
              isVerified
                  ? 'Start by creating your first service\nand reach more customers!'
                  : 'Your account must be verified by admin\nbefore you can create services.',
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: AppTheme.of(context).secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Action button
            if (isVerified)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomButton(
                  buttonText: 'Create Your First Service',
                  onTap: () {
                    Get.to(() => const CreateServiceScreen());
                  },
                  isExpanded: true,
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.of(context).warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.of(context).warning,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Waiting for admin verification',
                      style: AppTheme.of(context).bodyMedium.copyWith(
                        color: AppTheme.of(context).warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            // Tips section (only for verified users)
            if (isVerified) ...[
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).textFieldColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.of(context).warning,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Quick Tips',
                          style: AppTheme.of(
                            context,
                          ).headlineSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _TipItem(
                      icon: Icons.description_outlined,
                      title: 'Write Detailed Descriptions',
                      text:
                          'Explain what your service includes and what makes it special. Be specific about the work you do.',
                    ),
                    SizedBox(height: 16.h),
                    _TipItem(
                      icon: Icons.attach_money_outlined,
                      title: 'Set Your Pricing',
                      text:
                          'Choose hourly rates or fixed prices. Competitive pricing helps you get more bookings.',
                    ),
                    SizedBox(height: 16.h),
                    _TipItem(
                      icon: Icons.photo_camera_outlined,
                      title: 'Add Service Photos',
                      text:
                          'Show examples of your work. Good photos help customers trust your service quality.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.of(context).accent1.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: AppTheme.of(context).accent1),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.of(context).bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.of(context).primaryText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                text,
                style: AppTheme.of(context).bodySmall.copyWith(
                  color: AppTheme.of(context).secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
