import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/bookings_controller.dart';
import 'package:home_cleaning_app/controllers/nav_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/bookings/my_bookings_screen.dart';
import 'package:home_cleaning_app/views/screens/chat/messages_screen.dart';
import 'package:home_cleaning_app/views/screens/nav_pages/profile_screen.dart';
import 'package:home_cleaning_app/views/screens/services/create_service_screen.dart';
import 'package:home_cleaning_app/views/screens/services/services_catalog_screen.dart';

class NavPage extends StatelessWidget {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController());
    final authController = Get.find<AuthController>();
    final isCleaner = authController.userModel?.userType == UserType.cleaner;
    final isVerified = authController.userModel?.isVerified ?? false;
    return GetBuilder<NavController>(
      init: Get.put(NavController()),
      builder: (navController) {
        Get.put(BookingsController());
        return Scaffold(
          backgroundColor: AppTheme.of(context).primaryBackground,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: IndexedStack(
                index: navController.tabIndex,
                children: [
                  // Center(child: Text('Coming soon...')),
                  ServicesCatalogScreen(),
                  MyBookingsScreen(),
                  MessagesScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navController.tabIndex,
            onTap: (index) {
              navController.changeTabIndex(index);
            },
            backgroundColor: AppTheme.of(context).primaryBackground,
            selectedItemColor: AppTheme.of(context).accent1,
            unselectedItemColor: AppTheme.of(context).secondaryText,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.home_outlined, size: 22.0),
              //   activeIcon: Icon(Icons.home, size: 24.0),
              //   label: 'Home',
              //   tooltip: '',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cleaning_services_outlined, size: 22.0),
                activeIcon: Icon(Icons.cleaning_services, size: 24.0),
                label: 'Services',
                tooltip: '',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined, size: 22.0),
                activeIcon: Icon(Icons.calendar_today, size: 24.0),
                label: 'Bookings',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline, size: 22.0),
                activeIcon: Icon(Icons.chat_bubble, size: 24.0),
                label: 'Messages',
                tooltip: '',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined, size: 22.0),
                activeIcon: Icon(Icons.person, size: 24.0),
                label: 'Profile',
                tooltip: '',
              ),
            ],
          ),
          // ------------------------ Floating action button Section ------------------------
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: GetBuilder(
            init: controller,
            builder: (controller) {
              return isCleaner && isVerified
                  ? FloatingActionButton(
                      onPressed: () {
                        Get.to(() => const CreateServiceScreen());
                      },
                      backgroundColor: AppTheme.of(context).accent1,
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  : const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
