import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/views/screens/notifications/notifications_screen.dart';
import 'package:home_cleaning_app/views/screens/provider/stripe_connect_onboarding_screen.dart';
import 'package:home_cleaning_app/views/widgets/custom_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isProvider = authController.userModel?.userType == UserType.cleaner;

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 80.h),
              Text('Settings', style: AppTheme.of(context).displaySmall),
              SizedBox(height: 10.h),
              // CustomListTile(
              //   title: 'Account',
              //   prefixIcon: Icons.person_outline,
              // ),
              // SizedBox(height: 10.h),
              // Show Payment Setup for providers
              if (isProvider) ...[
                CustomListTile(
                  title: 'Payment Setup',
                  prefixIcon: Icons.account_balance_wallet,
                  onTap: () {
                    Get.to(() => const StripeConnectOnboardingScreen());
                  },
                ),
                SizedBox(height: 10.h),
              ],
              CustomListTile(
                title: 'Notifications',
                prefixIcon: Icons.notifications_outlined,
                onTap: () {
                  Get.to(() => const NotificationsScreen());
                },
              ),
              SizedBox(height: 10.h),
              CustomListTile(
                title: 'Log out',
                prefixIcon: Icons.logout_outlined,
                onTap: () => Get.find<AuthController>().signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
