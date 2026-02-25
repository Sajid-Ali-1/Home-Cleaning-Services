import 'package:get/get.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/services/qr_code_service.dart';
import 'package:home_cleaning_app/services/booking_db_service.dart';
import 'package:home_cleaning_app/services/notification_service.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingCompletionController extends GetxController {
  BookingCompletionController({required this.booking});

  final BookingModel booking;
  final RxBool isGeneratingQr = false.obs;
  final RxBool isCompleting = false.obs;
  final RxString qrCodeData = ''.obs;
  final RxString errorMessage = ''.obs;

  bool get canShowQrCode {
    if (booking.status != BookingStatus.accepted) return false;
    if (booking.completionTokenScannedAt != null) return false;
    return QrCodeService.canGenerateQrCode(booking.startTime.toDate());
  }

  bool get isQrCodeExpired {
    return QrCodeService.isQrCodeExpired(booking.startTime.toDate());
  }

  Future<void> generateQrCode() async {
    if (booking.bookingId == null) {
      errorMessage.value = 'Booking ID is missing';
      return;
    }

    isGeneratingQr.value = true;
    errorMessage.value = '';

    try {
      final qrData = await QrCodeService.generateCompletionQrCode(
        bookingId: booking.bookingId!,
        startTime: booking.startTime.toDate(),
      );
      qrCodeData.value = qrData;
    } catch (e) {
      errorMessage.value = 'Failed to generate QR code: ${e.toString()}';
    } finally {
      isGeneratingQr.value = false;
    }
  }

  Future<bool> completeBooking(String verificationToken) async {
    if (booking.bookingId == null) return false;

    isCompleting.value = true;
    errorMessage.value = '';

    try {
      // Validate QR code
      final isValid = await QrCodeService.validateQrCode(
        bookingId: booking.bookingId!,
        verificationToken: verificationToken,
        providerId: booking.providerId,
      );

      if (!isValid) {
        errorMessage.value = 'Invalid or expired QR code';
        return false;
      }

      // Update booking status to completed
      await BookingDbService.updateStatus(
        booking.bookingId!,
        BookingStatus.completed,
        extra: {
          'completedAt': FieldValue.serverTimestamp(),
          'payoutStatus': 'pending',
          'completionTokenScannedAt': FieldValue.serverTimestamp(),
        },
      );

      // Notify customer
      await NotificationService.sendNotificationToUser(
        userId: booking.customerId,
        title: 'Service completed',
        body: 'Your ${booking.serviceTitle} service has been completed.',
        type: NotificationType.bookingCompleted,
        data: {
          'bookingId': booking.bookingId ?? '',
          'userId': booking.customerId,
          'status': 'completed',
        },
      );

      // Notify provider about pending payout
      await NotificationService.sendNotificationToUser(
        userId: booking.providerId,
        title: 'Booking completed',
        body:
            'Payment will be processed within 24-48 hours. You will be notified when funds are transferred.',
        type: NotificationType.bookingCompleted,
        data: {
          'bookingId': booking.bookingId ?? '',
          'userId': booking.providerId,
          'status': 'completed',
          'payoutStatus': 'pending',
        },
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to complete booking: ${e.toString()}';
      return false;
    } finally {
      isCompleting.value = false;
    }
  }
}
