import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class UserTypeSelector extends StatelessWidget {
  const UserTypeSelector({
    super.key,
    required this.selectedUserType,
    required this.onUserTypeChanged,
    this.label,
  });

  final UserType selectedUserType;
  final ValueChanged<UserType> onUserTypeChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.of(context).bodyMedium),
          SizedBox(height: 12.h),
        ],
        Row(
          children: [
            Expanded(
              child: UserTypeOption(
                userType: UserType.customer,
                label: 'Customer',
                isSelected: selectedUserType == UserType.customer,
                onTap: () => onUserTypeChanged(UserType.customer),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: UserTypeOption(
                userType: UserType.cleaner,
                label: 'Cleaner',
                isSelected: selectedUserType == UserType.cleaner,
                onTap: () => onUserTypeChanged(UserType.cleaner),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UserTypeOption extends StatelessWidget {
  const UserTypeOption({
    super.key,
    required this.userType,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final UserType userType;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).accent1.withOpacity(0.2)
              : AppTheme.of(context).secondaryBackground,
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).accent1
                : AppTheme.of(context).dividerColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppTheme.of(context).accent1
                  : AppTheme.of(context).secondaryText,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTheme.of(context).bodyMedium.copyWith(
                color: isSelected
                    ? AppTheme.of(context).accent1
                    : AppTheme.of(context).secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
