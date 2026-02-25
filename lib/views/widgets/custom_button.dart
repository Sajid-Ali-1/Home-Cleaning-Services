import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.buttonText,
    this.onTap,
    this.buttonColor,
    this.borderedButtonColor,
    this.isLoading = false,
    this.isExpanded = true,
    this.isDense = false,
    this.style,
    this.prefix,
  });

  final String buttonText;
  final void Function()? onTap;
  final Color? buttonColor;
  final Color? borderedButtonColor;
  final bool isLoading;
  final bool isExpanded;
  final bool isDense;
  final TextStyle? style;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    var text = Text(
      buttonText,
      style:
          style?.copyWith(color: borderedButtonColor ?? Colors.white) ??
          AppTheme.of(
            context,
          ).displaySmall.copyWith(color: borderedButtonColor ?? Colors.white),
    );
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: isExpanded ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: isDense ? 10.r : 16.r,
          horizontal: 24.r,
        ),
        decoration: BoxDecoration(
          color: borderedButtonColor != null
              ? AppTheme.of(context).borderColor
              : buttonColor ?? AppTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(12.r),
          border: borderedButtonColor != null
              ? Border.all(color: borderedButtonColor!)
              : null,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 25.sp,
                  height: 25.sp,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : isExpanded
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefix != null) ...[prefix!, SizedBox(width: 10.r)],
                  text,
                ],
              )
            : text,
      ),
    );
  }
}
