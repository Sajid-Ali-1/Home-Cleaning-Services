import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicesCategoryChips extends StatelessWidget {
  const ServicesCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final ServiceCategory? selectedCategory;
  final Function(ServiceCategory?) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    Get.find<ServiceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore Categories',
              style: AppTheme.of(
                context,
              ).bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            // // View Toggle Button
            // Obx(() => IconButton(
            //       onPressed: () => serviceController.toggleViewMode(),
            //       icon: Icon(
            //         serviceController.isListView.value
            //             ? Icons.grid_view_outlined
            //             : Icons.list_outlined,
            //         color: AppTheme.of(context).primaryText,
            //         size: 24.sp,
            //       ),
            //       tooltip: serviceController.isListView.value
            //           ? 'Switch to Grid View'
            //           : 'Switch to List View',
            //     )),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 60.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CategoryChip(
                label: 'All Services',
                icon: Icons.home_outlined,
                isSelected: selectedCategory == null,
                onTap: () => onCategorySelected(null),
              ),
              SizedBox(width: 8.w),
              _CategoryChip(
                label: 'Cleaning',
                icon: Icons.cleaning_services,
                isSelected: selectedCategory == ServiceCategory.cleaning,
                onTap: () => onCategorySelected(ServiceCategory.cleaning),
              ),
              SizedBox(width: 8.w),
              _CategoryChip(
                label: 'Landscaping',
                icon: Icons.landscape_outlined,
                isSelected: selectedCategory == ServiceCategory.landscaping,
                onTap: () => onCategorySelected(ServiceCategory.landscaping),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).accent1
              : AppTheme.of(context).textFieldColor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? Colors.white
                  : AppTheme.of(context).primaryText,
            ),
            Text(
              label,
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.of(context).primaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
