import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class StepperControls extends StatelessWidget {
  const StepperControls({
    super.key,
    required this.stepIndex,
    required this.onStepContinue,
    required this.onStepCancel,
  });

  final int stepIndex;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;

  @override
  Widget build(BuildContext context) {
    final formController = Get.find<CreateServiceFormController>();
    final serviceController = Get.find<ServiceController>();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          if (stepIndex > 0) Expanded(child: _BackButton(onTap: onStepCancel)),
          if (stepIndex > 0) SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => _NextButton(
                buttonText: stepIndex == formController.totalSteps - 1
                    ? 'Save Service'
                    : 'Next',
                onTap: onStepContinue ?? () {},
                isLoading: serviceController.isCreatingService.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.buttonText,
    required this.onTap,
    required this.isLoading,
  });

  final String buttonText;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.of(context).accent1,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              buttonText,
              style: AppTheme.of(context).bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: BorderSide(
          color: AppTheme.of(context).accent1,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        'Back',
        style: AppTheme.of(context).bodyMedium.copyWith(
          color: AppTheme.of(context).accent1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
