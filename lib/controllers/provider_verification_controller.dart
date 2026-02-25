import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/models/provider_verification_model.dart';
import 'package:home_cleaning_app/services/provider_verification_service.dart';
import 'package:home_cleaning_app/services/storage_services.dart';

class ProviderVerificationController extends GetxController {
  ProviderVerification? verification;
  List<PlatformFile> selectedFiles = [];
  bool isLoading = false;
  bool isSubmitting = false;

  Future<void> loadVerification(String providerId) async {
    try {
      isLoading = true;
      update();
      verification = await ProviderVerificationService.getVerification(
        providerId,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load verification: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedFiles.addAll(result.files);
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick documents: $e');
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      update();
    }
  }

  bool get hasPendingRequest =>
      verification?.status == ProviderVerificationStatus.pending;

  bool get isRejected =>
      verification?.status == ProviderVerificationStatus.rejected;

  Future<void> submitVerification({
    required String providerId,
    required String providerName,
    required String providerEmail,
  }) async {
    if (selectedFiles.isEmpty) {
      Get.snackbar('Add Documents', 'Please attach your documents.');
      return;
    }

    try {
      isSubmitting = true;
      update();

      final uploadedDocs = <ProviderVerificationDocument>[];
      for (final file in selectedFiles) {
        if (file.path == null) continue;
        final fileUrl = await StorageServices.uploadVerificationDocument(
          file: File(file.path!),
          providerId: providerId,
        );
        uploadedDocs.add(
          ProviderVerificationDocument(
            name: file.name,
            url: fileUrl,
            type: file.extension ?? 'file',
            uploadedAt: DateTime.now(),
          ),
        );
      }

      verification = await ProviderVerificationService.submitVerification(
        providerId: providerId,
        providerName: providerName,
        providerEmail: providerEmail,
        documents: uploadedDocs,
      );
      selectedFiles.clear();
      Get.snackbar('Submitted', 'Your documents have been sent for review.');
    } catch (e) {
      kDebugMode
          ? Get.snackbar('Error', e.toString())
          : Get.snackbar('Error', 'Failed to submit verification');
    } finally {
      isSubmitting = false;
      update();
    }
  }
}
