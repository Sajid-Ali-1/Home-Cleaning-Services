import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  requested,
  accepted,
  completed,
  rejected,
  canceled;

  String toJson() => name;

  static BookingStatus fromJson(String? value) {
    if (value == null) return BookingStatus.requested;
    return BookingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BookingStatus.requested,
    );
  }
}

enum RefundStatus {
  pending,
  processing,
  completed,
  failed;

  String toJson() => name;

  static RefundStatus? fromJson(String? value) {
    if (value == null) return null;
    try {
      return RefundStatus.values.firstWhere((status) => status.name == value);
    } catch (e) {
      return null;
    }
  }
}

enum PayoutStatus {
  pending,
  processing,
  completed,
  failed;

  String toJson() => name;

  static PayoutStatus? fromJson(String? value) {
    if (value == null) return null;
    try {
      return PayoutStatus.values.firstWhere((status) => status.name == value);
    } catch (e) {
      return null;
    }
  }
}

class BookingModel {
  BookingModel({
    this.bookingId,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerId,
    required this.customerId,
    required this.startTime,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    required this.status,
    this.providerName,
    this.customerName,
    this.serviceThumbnail,
    this.paymentIntentId,
    this.paymentMethodId,
    this.paymentMethodLabel,
    this.notes,
    this.chatRoomId,
    this.selections = const [],
    this.refundStatus,
    this.refundId,
    this.refundReason,
    this.refundProcessedAt,
    this.refundAmount,
    this.refundCurrency,
    this.createdAt,
    this.updatedAt,
    this.customerLatitude,
    this.customerLongitude,
    this.customerAddress,
    this.completionToken,
    this.completionTokenExpiresAt,
    this.completionTokenScannedAt,
    this.completedAt,
    this.payoutStatus,
    this.payoutId,
    this.payoutAmount,
    this.platformFee,
    this.payoutProcessedAt,
    this.payoutError,
  });

  final String? bookingId;
  final String serviceId;
  final String serviceTitle;
  final String providerId;
  final String customerId;
  final Timestamp startTime;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final BookingStatus status;
  final String? providerName;
  final String? customerName;
  final String? serviceThumbnail;
  final String? paymentIntentId;
  final String? paymentMethodId;
  final String? paymentMethodLabel;
  final String? notes;
  final String? chatRoomId;
  final List<Map<String, dynamic>> selections;
  final RefundStatus? refundStatus;
  final String? refundId;
  final String? refundReason;
  final Timestamp? refundProcessedAt;
  final double? refundAmount;
  final String? refundCurrency;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final double? customerLatitude;
  final double? customerLongitude;
  final String? customerAddress;
  final String? completionToken;
  final Timestamp? completionTokenExpiresAt;
  final Timestamp? completionTokenScannedAt;
  final Timestamp? completedAt;
  final PayoutStatus? payoutStatus;
  final String? payoutId;
  final double? payoutAmount;
  final double? platformFee;
  final Timestamp? payoutProcessedAt;
  final String? payoutError;

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'providerId': providerId,
      'customerId': customerId,
      'providerName': providerName,
      'customerName': customerName,
      'serviceThumbnail': serviceThumbnail,
      'startTime': startTime,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'currency': currency,
      'status': status.toJson(),
      'paymentIntentId': paymentIntentId,
      'paymentMethodId': paymentMethodId,
      'paymentMethodLabel': paymentMethodLabel,
      'notes': notes,
      'chatRoomId': chatRoomId,
      'selections': selections,
      'refundStatus': refundStatus?.toJson(),
      'refundId': refundId,
      'refundReason': refundReason,
      'refundProcessedAt': refundProcessedAt,
      'refundAmount': refundAmount,
      'refundCurrency': refundCurrency,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'customerLatitude': customerLatitude,
      'customerLongitude': customerLongitude,
      'customerAddress': customerAddress,
      'completionToken': completionToken,
      'completionTokenExpiresAt': completionTokenExpiresAt,
      'completionTokenScannedAt': completionTokenScannedAt,
      'completedAt': completedAt,
      'payoutStatus': payoutStatus?.toJson(),
      'payoutId': payoutId,
      'payoutAmount': payoutAmount,
      'platformFee': platformFee,
      'payoutProcessedAt': payoutProcessedAt,
      'payoutError': payoutError,
    };
  }

  factory BookingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      serviceId: data['serviceId'] as String? ?? '',
      serviceTitle: data['serviceTitle'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      providerName: data['providerName'] as String?,
      customerName: data['customerName'] as String?,
      serviceThumbnail: data['serviceThumbnail'] as String?,
      startTime: (data['startTime'] as Timestamp?) ?? Timestamp.now(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'usd',
      status: BookingStatus.fromJson(data['status'] as String?),
      paymentIntentId: data['paymentIntentId'] as String?,
      paymentMethodId: data['paymentMethodId'] as String?,
      paymentMethodLabel: data['paymentMethodLabel'] as String?,
      notes: data['notes'] as String?,
      chatRoomId: data['chatRoomId'] as String?,
      selections:
          (data['selections'] as List<dynamic>?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          const [],
      refundStatus: RefundStatus.fromJson(data['refundStatus'] as String?),
      refundId: data['refundId'] as String?,
      refundReason: data['refundReason'] as String?,
      refundProcessedAt: data['refundProcessedAt'] as Timestamp?,
      refundAmount: (data['refundAmount'] as num?)?.toDouble(),
      refundCurrency: data['refundCurrency'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      customerLatitude: (data['customerLatitude'] as num?)?.toDouble(),
      customerLongitude: (data['customerLongitude'] as num?)?.toDouble(),
      customerAddress: data['customerAddress'] as String?,
      completionToken: data['completionToken'] as String?,
      completionTokenExpiresAt: data['completionTokenExpiresAt'] as Timestamp?,
      completionTokenScannedAt: data['completionTokenScannedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
      payoutStatus: PayoutStatus.fromJson(data['payoutStatus'] as String?),
      payoutId: data['payoutId'] as String?,
      payoutAmount: (data['payoutAmount'] as num?)?.toDouble(),
      platformFee: (data['platformFee'] as num?)?.toDouble(),
      payoutProcessedAt: data['payoutProcessedAt'] as Timestamp?,
      payoutError: data['payoutError'] as String?,
    );
  }

  BookingModel copyWith({
    String? bookingId,
    BookingStatus? status,
    String? paymentIntentId,
    String? paymentMethodId,
    String? paymentMethodLabel,
    String? notes,
    String? chatRoomId,
    RefundStatus? refundStatus,
    String? refundId,
    String? refundReason,
    Timestamp? refundProcessedAt,
    double? refundAmount,
    String? refundCurrency,
    Timestamp? updatedAt,
    double? customerLatitude,
    double? customerLongitude,
    String? customerAddress,
    String? completionToken,
    Timestamp? completionTokenExpiresAt,
    Timestamp? completionTokenScannedAt,
    Timestamp? completedAt,
    PayoutStatus? payoutStatus,
    String? payoutId,
    double? payoutAmount,
    double? platformFee,
    Timestamp? payoutProcessedAt,
    String? payoutError,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      providerId: providerId,
      customerId: customerId,
      startTime: startTime,
      subtotal: subtotal,
      tax: tax,
      total: total,
      currency: currency,
      status: status ?? this.status,
      providerName: providerName,
      customerName: customerName,
      serviceThumbnail: serviceThumbnail,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
      notes: notes ?? this.notes,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      selections: selections,
      refundStatus: refundStatus ?? this.refundStatus,
      refundId: refundId ?? this.refundId,
      refundReason: refundReason ?? this.refundReason,
      refundProcessedAt: refundProcessedAt ?? this.refundProcessedAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundCurrency: refundCurrency ?? this.refundCurrency,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      customerAddress: customerAddress ?? this.customerAddress,
      completionToken: completionToken ?? this.completionToken,
      completionTokenExpiresAt: completionTokenExpiresAt ?? this.completionTokenExpiresAt,
      completionTokenScannedAt: completionTokenScannedAt ?? this.completionTokenScannedAt,
      completedAt: completedAt ?? this.completedAt,
      payoutStatus: payoutStatus ?? this.payoutStatus,
      payoutId: payoutId ?? this.payoutId,
      payoutAmount: payoutAmount ?? this.payoutAmount,
      platformFee: platformFee ?? this.platformFee,
      payoutProcessedAt: payoutProcessedAt ?? this.payoutProcessedAt,
      payoutError: payoutError ?? this.payoutError,
    );
  }
}
