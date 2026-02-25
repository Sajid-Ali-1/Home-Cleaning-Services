import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicesSearchBar extends StatelessWidget {
  const ServicesSearchBar({
    super.key,
    required this.onChanged,
    this.onFilterTap,
    this.isSearching = false,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            style: AppTheme.of(context).bodySmall,
            decoration: InputDecoration(
              hintText: 'Search services...',
              hintStyle: AppTheme.of(
                context,
              ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.of(context).secondaryText,
                size: 20.sp,
              ),
              suffixIcon: isSearching
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.of(context).accent1,
                          ),
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.of(context).textFieldColor,
              border: inputBorder,
              focusedBorder: inputBorder,
              enabledBorder: inputBorder,
              errorBorder: inputBorder,
              focusedErrorBorder: inputBorder,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            cursorColor: AppTheme.of(context).accent1,
          ),
        ),
        // SizedBox(width: 12.w),
        // // Filter Button
        // Container(
        //   width: 48.w,
        //   height: 48.w,
        //   decoration: BoxDecoration(
        //     color: AppTheme.of(context).accent1,
        //     borderRadius: BorderRadius.circular(12.r),
        //   ),
        //   child: IconButton(
        //     onPressed: onFilterTap,
        //     icon: Icon(Icons.tune, color: Colors.white, size: 20.sp),
        //   ),
        // ),
      ],
    );
  }
}
