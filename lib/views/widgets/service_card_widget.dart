import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServiceCardWidget extends StatelessWidget {
  const ServiceCardWidget({
    super.key,
    required this.service,
    this.isListView = false,
    this.onTap,
  });

  final ServiceModel service;
  final bool isListView;
  final VoidCallback? onTap;

  String _getPriceDisplay() {
    final primaryOption = service.primaryPricingOption;
    if (primaryOption != null && primaryOption.pricePerUnit > 0) {
      return '\$${primaryOption.pricePerUnit.toStringAsFixed(0)}/${primaryOption.unitDisplay}';
    }
    if (service.basePrice != null && service.basePrice! > 0) {
      return '\$${service.basePrice!.toStringAsFixed(0)} flat';
      }
    final minPrice = service.getMinPrice();
    if (minPrice != null) {
      return '\$${minPrice.toStringAsFixed(0)}';
    }
    return 'Price on request';
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isListView ? double.infinity : null,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // ----------------------------------------------------------
            // ------------------------ Image Section ------------------------
            // ----------------------------------------------------------
            Stack(
              children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
          child: service.images != null && service.images!.isNotEmpty
              ? Image.network(
                  service.images!.first,
                  width: double.infinity,
                          height: 160.h,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                          height: 160.h,
                  color: AppTheme.of(context).textFieldColor,
                  child: Icon(
                    Icons.image_outlined,
                    size: 40.sp,
                    color: AppTheme.of(context).secondaryText,
                  ),
                ),
        ),
                // ------------------------ Price badge Section ------------------------
                Positioned(
                  left: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).accent1,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _getPriceDisplay(),
                      style: AppTheme.of(context).bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ----------------------------------------------------------
            // ------------------------ Content Section ------------------------
            // ----------------------------------------------------------
            Padding(
              padding: EdgeInsets.all(13.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------ Title Section ------------------------
                  Text(
                    service.title ?? '',
                    style: AppTheme.of(
                      context,
                    ).bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // ------------------------ Description Section ------------------------
              if (service.description != null)
                Text(
                  service.description!,
                      style: AppTheme.of(context).bodySmall.copyWith(
                        color: AppTheme.of(context).secondaryText,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                  SizedBox(height: 6.h),
                  // ------------------------ Location Section ------------------------
                  if (service.location != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            service.location!,
                            style: AppTheme.of(context).bodySmall
                                .copyWith(
                                  color: AppTheme.of(
                                    context,
                                  ).secondaryText,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 8.h),
                  // ------------------------ View Details Button Section ------------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.of(context).accent1,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'View Details',
                        style: AppTheme.of(context).bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
        ),
      ),
    );
  }
}
