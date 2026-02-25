import 'package:cloud_firestore/cloud_firestore.dart';

enum ProviderVerificationStatus { pending, approved, rejected }

extension ProviderVerificationStatusX on ProviderVerificationStatus {
  String toJson() => name;

  static ProviderVerificationStatus fromJson(String? value) {
    return ProviderVerificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ProviderVerificationStatus.pending,
    );
  }
}

class ProviderVerificationDocument {
  final String name;
  final String url;
  final String type;
  final DateTime uploadedAt;

  ProviderVerificationDocument({
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  factory ProviderVerificationDocument.fromMap(Map<String, dynamic> map) {
    return ProviderVerificationDocument(
      name: map['name'] as String? ?? '',
      url: map['url'] as String? ?? '',
      type: map['type'] as String? ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'uploadedAt': uploadedAt,
    };
  }
}

class ProviderVerification {
  final String providerId;
  final String providerName;
  final String providerEmail;
  final ProviderVerificationStatus status;
  final List<ProviderVerificationDocument> documents;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? rejectionReason;

  ProviderVerification({
    required this.providerId,
    required this.providerName,
    required this.providerEmail,
    required this.status,
    required this.documents,
    this.submittedAt,
    this.reviewedAt,
    this.reviewerId,
    this.rejectionReason,
  });

  factory ProviderVerification.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final documentsData = (data['documents'] as List<dynamic>? ?? [])
        .map(
          (doc) => ProviderVerificationDocument.fromMap(
            doc as Map<String, dynamic>,
          ),
        )
        .toList();

    return ProviderVerification(
      providerId: doc.id,
      providerName: data['providerName'] as String? ?? '',
      providerEmail: data['providerEmail'] as String? ?? '',
      status: ProviderVerificationStatusX.fromJson(
        data['status'] as String?,
      ),
      documents: documentsData,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewerId: data['reviewerId'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerName': providerName,
      'providerEmail': providerEmail,
      'status': status.toJson(),
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'submittedAt': submittedAt ?? FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt,
      'reviewerId': reviewerId,
      'rejectionReason': rejectionReason,
    };
  }
}


