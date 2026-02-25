import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class StepperStepBuilder {
  static Step buildStep({
    required String title,
    required Widget content,
    required int stepIndex,
    required CreateServiceFormController controller,
  }) {
    return Step(
      title: Text(
        title,
        style: AppTheme.of(
          Get.context!,
        ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      stepStyle: StepStyle(
        color: controller.currentStep.value >= stepIndex
            ? AppTheme.of(Get.context!).accent1
            : AppTheme.of(Get.context!).textFieldColor,
        indexStyle: AppTheme.of(Get.context!).bodySmall.copyWith(
          color: controller.currentStep.value >= stepIndex
              ? Colors.white
              : AppTheme.of(Get.context!).primaryText,
        ),
      ),
      content: content,
      isActive: controller.currentStep.value == stepIndex,
      state: _getStepState(stepIndex, controller),
    );
  }

  static StepState _getStepState(
    int stepIndex,
    CreateServiceFormController controller,
  ) {
    final currentStep = controller.currentStep.value;
    final isActive = currentStep == stepIndex;

    // Only mark as complete if step is before the current step (completed steps)
    if (stepIndex < currentStep) {
      return StepState.complete;
    }

    // Current step is active
    if (isActive) {
      return StepState.indexed;
    }

    // Future steps are disabled (but not grey - we'll style them differently)
    return StepState.indexed;
  }
}
