import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/step1_basic_info.dart';
import 'package:home_cleaning_app/views/widgets/create_service/step2_pricing.dart';
import 'package:home_cleaning_app/views/widgets/create_service/step3_availability.dart';
import 'package:home_cleaning_app/views/widgets/create_service/step4_service_area.dart';
import 'package:home_cleaning_app/views/widgets/create_service/step5_images.dart';
import 'package:home_cleaning_app/views/widgets/create_service/stepper_controls.dart';
import 'package:home_cleaning_app/views/widgets/create_service/stepper_step_builder.dart';

class CreateServiceScreen extends StatelessWidget {
  const CreateServiceScreen({super.key, this.service});

  final ServiceModel? service;

  @override
  Widget build(BuildContext context) {
    // Register controller first (without tag for simplicity)
    final formController = Get.put(CreateServiceFormController());
    final serviceController = Get.find<ServiceController>();
    final authController = Get.find<AuthController>();

    // Load service data if editing
    if (service != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formController.loadServiceData(service!);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: AppTheme.of(context).primaryText),
        elevation: 0,
        title: Text(
          service != null ? 'Edit Service' : 'Create Service',
          style: AppTheme.of(context).displaySmall,
        ),
      ),
      body: Obx(() {
        final accentColor = AppTheme.of(context).accent1;
        final secondaryText = AppTheme.of(context).secondaryText;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary:
                  accentColor, // Used for active step and completed step circle background
              onPrimary: Colors
                  .white, // Checkmark color on completed steps (white checkmark on accent1 circle)
              onSurface: secondaryText, // Used for inactive steps
            ),
          ),
          child: Stepper(
            currentStep: formController.currentStep.value,
            onStepTapped: (step) {
              // Allow navigation to previous steps only
              if (step < formController.currentStep.value) {
                formController.goToStep(step);
              }
            },
            onStepContinue: () {
              if (formController.validateCurrentStep()) {
                if (formController.currentStep.value ==
                    formController.totalSteps - 1) {
                  _handleSaveService(
                    formController,
                    serviceController,
                    authController,
                  );
                } else {
                  formController.nextStep();
                }
              } else {
                // Show error message for failed validation
                final step = formController.currentStep.value;
                String errorMessage = 'Please complete all required fields';
                if (step == 1) {
                  // Step 2: Pricing
                  final hasOptions = formController.pricingOptions.isNotEmpty;
                  if (!hasOptions) {
                    errorMessage =
                        'Please add at least one pricing option to continue';
                  } else {
                    errorMessage =
                        'Please complete all pricing option details (price, unit, and name)';
                  }
                }
                Get.snackbar(
                  'Validation Error',
                  errorMessage,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.of(context).error.withOpacity(0.9),
                  colorText: Colors.white,
                );
              }
            },
            onStepCancel: () {
              if (formController.currentStep.value > 0) {
                formController.previousStep();
              } else {
                Get.back();
              }
            },
            controlsBuilder: (context, details) {
              return StepperControls(
                stepIndex: details.stepIndex,
                onStepContinue: details.onStepContinue,
                onStepCancel: details.onStepCancel,
              );
            },
            steps: [
              StepperStepBuilder.buildStep(
                title: 'Basic Information',
                content: const Step1BasicInfo(),
                stepIndex: 0,
                controller: formController,
              ),
              StepperStepBuilder.buildStep(
                title: 'Pricing',
                content: const Step2Pricing(),
                stepIndex: 1,
                controller: formController,
              ),
              StepperStepBuilder.buildStep(
                title: 'Availability',
                content: const Step3Availability(),
                stepIndex: 2,
                controller: formController,
              ),
              StepperStepBuilder.buildStep(
                title: 'Service Area',
                content: const Step4ServiceArea(),
                stepIndex: 3,
                controller: formController,
              ),
              StepperStepBuilder.buildStep(
                title: 'Images',
                content: const Step5Images(),
                stepIndex: 4,
                controller: formController,
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _handleSaveService(
    CreateServiceFormController formController,
    ServiceController serviceController,
    AuthController authController,
  ) async {
    final success = await formController.saveService(
      serviceController: serviceController,
      authController: authController,
      existingService: service,
    );

    if (success) {
      Get.back(result: true);
    }
  }
}
