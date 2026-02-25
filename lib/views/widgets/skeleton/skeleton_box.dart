import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/skeleton/shimmer_widget.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      baseColor: AppTheme.of(context).textFieldColor,
      highlightColor: AppTheme.of(context).textFieldColor.withOpacity(0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.of(context).textFieldColor,
          borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
