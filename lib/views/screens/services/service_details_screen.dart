import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/notifications/notifications_screen.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_availability_section.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_book_button.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_details_header.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_images_gallery.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_info_section.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_location_section.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_owner_actions.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_pricing_options_section.dart';
import 'package:home_cleaning_app/views/widgets/service_details_widgets/service_pricing_summary.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(ServiceDetailsController(service: service));

    final authController = Get.find<AuthController>();
    final currentUserId = authController.userModel?.uid;
    final isServiceOwner = controller.isServiceOwner(currentUserId);
    final isCustomer = authController.userModel?.userType == UserType.customer;

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.of(context).accent1,
            ),
          );
        }

        return Column(
          children: [
            // Header
            ServiceDetailsHeader(
              onNotificationTap: () {
                Get.to(() => const NotificationsScreen());
              },
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Gallery
                    const ServiceImagesGallery(),
                    // Service Info
                    const ServiceInfoSection(),
                    // Pricing Options
                    ServicePricingOptionsSection(isCustomerView: isCustomer),
                    // Pricing Summary
                    const ServicePricingSummary(),
                    // Location
                    if (isServiceOwner) const ServiceLocationSection(),
                    // Availability
                    if (isCustomer || isServiceOwner)
                      ServiceAvailabilitySection(
                        isCustomerView: isCustomer,
                        isOwnerView: isServiceOwner,
                      ),
                    // if (isCustomer)
                    //   Padding(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: 16.w,
                    //       vertical: 12.h,
                    //     ),
                    //     child: CustomButton(
                    //       buttonText: 'Chat with Provider',
                    //       onTap: controller.openChatWithProvider,
                    //       borderedButtonColor: AppTheme.of(context).accent1,
                    //       buttonColor: AppTheme.of(context).secondaryBackground,
                    //       style: AppTheme.of(context).bodyMedium.copyWith(
                    //         color: AppTheme.of(context).accent1,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    SizedBox(height: 40.h), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      // Bottom button - different for customers vs service owners
      bottomNavigationBar: Obx(() {
        final currentService = controller.currentService.value ?? service;
        if (isServiceOwner) {
          return ServiceOwnerActions(service: currentService);
        } else if (isCustomer) {
          return const ServiceBookButton();
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
