import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/provider_verification_controller.dart';
import 'package:home_cleaning_app/models/provider_verification_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/verification_pending_screen.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends State<ProviderVerificationScreen> {
  late final ProviderVerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProviderVerificationController());
    final userId = Get.find<AuthController>().userModel?.uid;
    if (userId != null) {
      controller.loadVerification(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = AppTheme.of(context);
    final user = authController.userModel;
    final providerId = user?.uid ?? '';
    final providerName =
        user?.displayName ?? authController.fullName ?? 'Service Provider';
    final providerEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        title: Text('Provider Documents', style: theme.displaySmall),
      ),
      body: GetBuilder<ProviderVerificationController>(
        init: controller,
        builder: (ctrl) {
          if (providerId.isEmpty) {
            return _EmptyState(
              message:
                  'We could not find your account details. Please sign in again.',
              theme: theme,
            );
          }

          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.hasPendingRequest) {
            return _PendingState(theme: theme);
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(theme: theme),
                  // SizedBox(height: 16.h),
                  // _ProviderInfo(
                  //   name: providerName,
                  //   email: providerEmail,
                  //   theme: theme,
                  //   status: ctrl.verification?.status,
                  // ),
                  if (ctrl.isRejected &&
                      ctrl.verification?.rejectionReason != null) ...[
                    SizedBox(height: 16.h),
                    _RejectionNotice(
                      reason:
                          ctrl.verification?.rejectionReason ??
                          'No reason provided',
                      documents: ctrl.verification?.documents ?? [],
                      theme: theme,
                    ),
                  ],
                  if (!ctrl.isRejected &&
                      ctrl.verification?.documents.isNotEmpty == true) ...[
                    SizedBox(height: 12.h),
                    _ExistingDocuments(
                      documents: ctrl.verification!.documents,
                      theme: theme,
                    ),
                  ],
                  SizedBox(height: 16.h),
                  _UploadSection(controller: ctrl, theme: theme),
                  SizedBox(height: 24.h),
                  CustomButton(
                    buttonText: ctrl.isSubmitting
                        ? 'Submitting...'
                        : 'Submit for Verification',
                    isLoading: ctrl.isSubmitting,
                    onTap: ctrl.isSubmitting
                        ? null
                        : () async {
                            await ctrl.submitVerification(
                              providerId: providerId,
                              providerName: providerName,
                              providerEmail: providerEmail,
                            );
                            await authController.refreshUserData();
                          },
                    isExpanded: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.of(context).primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppTheme.of(context).primary,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Submit documents',
                  style: AppTheme.of(context).headlineSmall.copyWith(
                    color: AppTheme.of(context).primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Our admin team will review your documents and get back to you within 24-48 hours.',
            style: AppTheme.of(
              context,
            ).bodyMedium.copyWith(color: AppTheme.of(context).primaryText),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 16.h),
          Divider(color: AppTheme.of(context).primary.withOpacity(0.3)),
          SizedBox(height: 12.h),
          Text(
            'What to upload:',
            style: theme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          _BulletPoint(
            text: 'Government ID or business registration',
            theme: theme,
          ),
          _BulletPoint(text: 'Proof of address or utility bill', theme: theme),
          _BulletPoint(
            text: 'Any licenses or certifications (optional)',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _RejectionNotice extends StatelessWidget {
  const _RejectionNotice({
    required this.reason,
    required this.documents,
    required this.theme,
  });

  final String reason;
  final List<ProviderVerificationDocument> documents;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: theme.error),
              SizedBox(width: 8.w),
              Text(
                'Previous submission was rejected',
                style: theme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            reason,
            style: theme.bodySmall.copyWith(color: theme.primaryText),
          ),
          SizedBox(height: 8.h),
          Text(
            'Resubmit your documents.',
            style: theme.bodySmall.copyWith(color: theme.secondaryText),
          ),
          if (documents.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(color: theme.error.withOpacity(0.3)),
            SizedBox(height: 12.h),
            Text(
              'Previously submitted documents:',
              style: theme.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                // color: theme.error,
              ),
            ),
            SizedBox(height: 8.h),
            ...documents.map(
              (doc) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () {
                    // Open document URL if needed
                    // You can add url_launcher package to open URLs
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppTheme.of(context).secondaryText,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          doc.name,
                          style: theme.bodySmall.copyWith(
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      Text(
                        doc.type.toUpperCase(),
                        style: theme.labelSmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExistingDocuments extends StatelessWidget {
  const _ExistingDocuments({required this.documents, required this.theme});

  final List<ProviderVerificationDocument> documents;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previously uploaded documents',
            style: theme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          ...documents.map(
            (doc) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: theme.accent1,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      doc.name,
                      style: theme.bodySmall.copyWith(color: theme.primaryText),
                    ),
                  ),
                  Text(
                    doc.type.toUpperCase(),
                    style: theme.labelSmall.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({required this.controller, required this.theme});

  final ProviderVerificationController controller;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        // color: theme.textFieldColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload documents',
                style: theme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'PDF, JPG, PNG',
                style: theme.labelSmall.copyWith(color: theme.secondaryText),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomButton(
            buttonText: 'Choose files',
            onTap: controller.pickDocuments,
            isExpanded: false,
          ),
          if (controller.selectedFiles.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...controller.selectedFiles.asMap().entries.map((entry) {
              final idx = entry.key;
              final file = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: theme.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, color: theme.accent1),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: theme.bodyMedium.copyWith(
                              color: theme.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatSize(file.size),
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.removeFile(idx),
                      icon: Icon(Icons.close, color: theme.secondaryText),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (controller.selectedFiles.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                'Attach your documents so our admin team can verify you.',
                style: theme.bodySmall.copyWith(color: theme.secondaryText),
              ),
            ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    }
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text, required this.theme});

  final String text;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.of(context).secondaryText,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: AppTheme.of(context).bodySmall)),
        ],
      ),
    );
  }
}

class _PendingState extends StatelessWidget {
  const _PendingState({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_bottom, size: 64.sp, color: theme.accent1),
            SizedBox(height: 16.h),
            Text(
              'Your documents are under review',
              style: theme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'We already have your submission. You can check the status anytime.',
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              buttonText: 'View Pending Status',
              onTap: () {
                Get.offAll(() => const VerificationPendingScreen());
              },
              isExpanded: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.theme});

  final String message;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: theme.error),
            SizedBox(height: 12.h),
            Text(
              message,
              style: theme.bodyMedium.copyWith(color: theme.primaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
