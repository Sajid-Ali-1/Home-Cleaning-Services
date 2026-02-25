import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/provider_verification_model.dart';

class ProviderVerificationService {
  static final CollectionReference _verificationRef =
      FirebaseFirestore.instance.collection('provider_verifications');

  static Future<ProviderVerification?> getVerification(String providerId) async {
    final doc = await _verificationRef.doc(providerId).get();
    if (!doc.exists) return null;
    return ProviderVerification.fromDocument(doc);
  }

  static Future<ProviderVerification> submitVerification({
    required String providerId,
    required String providerName,
    required String providerEmail,
    required List<ProviderVerificationDocument> documents,
  }) async {
    final verification = ProviderVerification(
      providerId: providerId,
      providerName: providerName,
      providerEmail: providerEmail,
      status: ProviderVerificationStatus.pending,
      documents: documents,
      rejectionReason: null,
      reviewedAt: null,
      reviewerId: null,
      submittedAt: DateTime.now(),
    );

    await _verificationRef.doc(providerId).set({
      ...verification.toMap(),
      'submittedAt': FieldValue.serverTimestamp(),
    });

    return verification;
  }
}


