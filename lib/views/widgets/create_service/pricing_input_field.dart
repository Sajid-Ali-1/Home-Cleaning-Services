import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class PricingInputField extends StatelessWidget {
  const PricingInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.of(context).bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.of(context).primaryText,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          cursorColor: AppTheme.of(context).accent1,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    size: 20.sp,
                    color: AppTheme.of(context).secondaryText,
                  )
                : null,
            prefixText: prefix,
            suffixText: suffix,
            suffixStyle: AppTheme.of(
              context,
            ).bodyMedium.copyWith(color: AppTheme.of(context).secondaryText),
            filled: true,
            fillColor: AppTheme.of(context).textFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
          ),
          style: AppTheme.of(context).bodyMedium,
        ),
      ],
    );
  }
}
