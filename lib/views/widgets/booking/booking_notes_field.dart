import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class BookingNotesField extends StatelessWidget {
  const BookingNotesField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes for provider',
          style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special requests or access notes?',
            hintStyle: theme.bodySmall.copyWith(color: theme.secondaryText),
            filled: true,
            fillColor: theme.textFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
