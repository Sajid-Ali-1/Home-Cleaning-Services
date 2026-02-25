import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/booking_model.dart';

class BookingDbService {
  static final CollectionReference _bookingsRef = FirebaseFirestore.instance
      .collection('bookings');

  static Future<String> createBooking(BookingModel booking) async {
    final docRef = await _bookingsRef.add(booking.toMap());
    return docRef.id;
  }

  static Future<void> updateStatus(
    String bookingId,
    BookingStatus status, {
    Map<String, dynamic>? extra,
  }) async {
    await _bookingsRef.doc(bookingId).update({
      'status': status.toJson(),
      if (extra != null) ...extra,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<BookingModel>> bookingsForUser(
    String userId, {
    required bool asProvider,
  }) {
    final query = _bookingsRef
        .where(asProvider ? 'providerId' : 'customerId', isEqualTo: userId)
        .orderBy('startTime', descending: false);
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => BookingModel.fromDocument(doc)).toList(),
    );
  }

  static Future<BookingModel?> getLatestBookingForService({
    required String serviceId,
    required String customerId,
  }) async {
    final query = await _bookingsRef
        .where('serviceId', isEqualTo: serviceId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return BookingModel.fromDocument(query.docs.first);
  }

  /// Get a booking by its ID
  static Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsRef.doc(bookingId).get();
      if (!doc.exists) return null;
      return BookingModel.fromDocument(doc);
    } catch (e) {
      print('Error fetching booking by ID: $e');
      return null;
    }
  }

  /// Updates refund information for a booking
  static Future<void> updateRefundInfo({
    required String bookingId,
    required RefundStatus refundStatus,
    String? refundId,
    String? refundReason,
    required double refundAmount,
    required String refundCurrency,
  }) async {
    final updateData = <String, dynamic>{
      'refundStatus': refundStatus.toJson(),
      'refundReason': refundReason,
      'refundAmount': refundAmount,
      'refundCurrency': refundCurrency,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Only set refundId if provided
    if (refundId != null && refundId.isNotEmpty) {
      updateData['refundId'] = refundId;
    }

    // Only set refundProcessedAt when refund is completed or failed
    if (refundStatus == RefundStatus.completed ||
        refundStatus == RefundStatus.failed) {
      updateData['refundProcessedAt'] = FieldValue.serverTimestamp();
    }

    await _bookingsRef.doc(bookingId).update(updateData);
  }
}
