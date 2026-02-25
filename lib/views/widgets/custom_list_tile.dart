import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.title,
    required this.prefixIcon,
    this.onTap,
  });

  final String title;
  final IconData prefixIcon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).bottomsheatBackground,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(prefixIcon),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(title, style: AppTheme.of(context).bodyMedium),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.of(context).textGreyColor,
              size: 15.0,
            ),
          ],
        ),
      ),
    );
  }
}
