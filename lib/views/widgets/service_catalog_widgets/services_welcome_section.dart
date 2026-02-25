import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServicesWelcomeSection extends StatelessWidget {
  const ServicesWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: AppTheme.of(context).displayMedium,
        ),
        SizedBox(height: 4.h),
        Text(
          'Find the perfect service for your home.',
          style: AppTheme.of(context).bodyMedium.copyWith(
            color: AppTheme.of(context).secondaryText,
          ),
        ),
      ],
    );
  }
}
