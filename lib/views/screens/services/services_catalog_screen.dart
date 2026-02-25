import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/customer_location_controller.dart';
import 'package:home_cleaning_app/controllers/nav_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/notifications/notifications_screen.dart';
import 'package:home_cleaning_app/views/screens/services/service_details_screen.dart';
import 'package:home_cleaning_app/views/widgets/service_card_widget.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_catalog_header.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_category_chips.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_empty_state_customer.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_filtered_empty_state.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_empty_state_provider.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_search_bar.dart';
import 'package:home_cleaning_app/views/widgets/service_catalog_widgets/services_welcome_section.dart';
import 'package:home_cleaning_app/views/widgets/skeleton/services_catalog_skeleton.dart';

class ServicesCatalogScreen extends StatelessWidget {
  const ServicesCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController());
    final authController = Get.find<AuthController>();
    final isCleaner = authController.userModel?.userType == UserType.cleaner;

    // Initialize CustomerLocationController for customers
    if (!isCleaner) {
      final locationController = Get.put(CustomerLocationController());
      // Listen to location changes and update filters
      ever(locationController.hasLocation, (hasLocation) {
        if (hasLocation) {
          // Small delay to ensure location values are set
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.applyFilters();
          });
        }
      });
      ever(locationController.latitude, (_) {
        if (locationController.hasLocation.value) {
          controller.applyFilters();
        }
      });
      ever(locationController.longitude, (_) {
        if (locationController.hasLocation.value) {
          controller.applyFilters();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Obx(() {
        // Show loading skeleton
        if (controller.isLoading.value) {
          return ServicesCatalogSkeleton(
            isCleaner: isCleaner,
            isListView: controller.isListView.value,
          );
        }

        // Show empty state if no services at all
        final servicesList = controller.currentServicesList;
        if (servicesList.isEmpty) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isCleaner
                ? const ServicesEmptyStateProvider(
                    key: ValueKey('empty_provider'),
                  )
                : const ServicesEmptyStateCustomer(
                    key: ValueKey('empty_customer'),
                  ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: const ValueKey('content'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------ Header Section ------------------------
              ServicesCatalogHeader(
                onNotificationTap: () {
                  Get.to(() => const NotificationsScreen());
                },
                onProfileTap: () {
                  final navController = Get.find<NavController>();
                  navController.changeTabIndex(4);
                },
              ),
              SizedBox(height: 12.h),

              // ------------------------ Search bar Section ------------------------
              Obx(
                () => ServicesSearchBar(
                  onChanged: (value) => controller.setSearchQuery(value),
                  onFilterTap: () {
                    // TODO: Show filter bottom sheet
                  },
                  isSearching: controller.isSearching.value,
                ),
              ),
              SizedBox(height: 19.h),
              // ------------------------ Welcome section (only for customers) ------------------------
              if (!isCleaner) ...[
                const ServicesWelcomeSection(),
                SizedBox(height: 16.h),
              ],

              // ------------------------ Category chips Section ------------------------
              ServicesCategoryChips(
                selectedCategory: controller.selectedCategory.value,
                onCategorySelected: (category) =>
                    controller.setCategoryFilter(category),
              ),
              SizedBox(height: 16.h),
              // ------------------------ Services grid Section ------------------------
              Expanded(
                child: Obx(() {
                  // ------------------------ Show filtered empty state ------------------------
                  if (controller.filteredServices.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(32.w),
                        child: ServicesFilteredEmptyState(
                          controller: controller,
                        ),
                      ),
                    );
                  }
                  if (controller.isListView.value) {
                    // ------------------------ Show services in list view ------------------------
                    return ListView.builder(
                      itemCount: controller.filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = controller.filteredServices[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ServiceCardWidget(
                            service: service,
                            isListView: true,
                            onTap: () {
                              Get.to(
                                () => ServiceDetailsScreen(service: service),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    // ------------------------ Show services in grid view ------------------------
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.45,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: controller.filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = controller.filteredServices[index];
                        return ServiceCardWidget(
                          service: service,
                          isListView: false,
                          onTap: () {
                            Get.to(
                              () => ServiceDetailsScreen(service: service),
                            );
                          },
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
