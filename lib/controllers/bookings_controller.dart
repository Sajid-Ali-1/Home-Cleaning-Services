import 'dart:async';

import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/services/booking_db_service.dart';
import 'package:home_cleaning_app/services/notification_service.dart';
import 'package:home_cleaning_app/services/qr_code_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingListFilter { requests, upcoming, past }

class BookingsController extends GetxController {
  BookingsController();

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<BookingListFilter> activeFilter = BookingListFilter.upcoming.obs;

  bool isProviderView = false;
  String? _userId;
  StreamSubscription<List<BookingModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    initializeBookings();
  }

  void initializeBookings() {
    try {
      // Cancel existing subscription if any
      _subscription?.cancel();

      final auth = Get.find<AuthController>();
      final currentUser = auth.userModel;
      if (currentUser == null || currentUser.uid == null) {
        isLoading.value = false;
        bookings.value = [];
        return;
      }
      _userId = currentUser.uid;
      isProviderView = currentUser.userType == UserType.cleaner;
      _listenToBookings();
    } catch (e) {
      print('Error initializing bookings: $e');
      isLoading.value = false;
      bookings.value = [];
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void changeFilter(BookingListFilter filter) {
    activeFilter.value = filter;
  }

  List<BookingModel> get filteredBookings {
    final now = DateTime.now();
    return bookings.where((booking) {
      final start = booking.startTime.toDate();
      switch (activeFilter.value) {
        case BookingListFilter.requests:
          return booking.status == BookingStatus.requested;
        case BookingListFilter.upcoming:
          return booking.status == BookingStatus.accepted && start.isAfter(now);
        case BookingListFilter.past:
          return booking.status == BookingStatus.completed ||
              booking.status == BookingStatus.rejected ||
              booking.status == BookingStatus.canceled ||
              booking.startTime.toDate().isBefore(now);
      }
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> acceptBooking(BookingModel booking) async {
    if (booking.bookingId == null) return;
    await BookingDbService.updateStatus(
      booking.bookingId!,
      BookingStatus.accepted,
    );
    await NotificationService.sendNotificationToUser(
      userId: booking.customerId,
      title: 'Booking accepted',
      body: '${booking.serviceTitle} has been accepted and scheduled.',
      type: NotificationType.bookingAccepted,
      data: {
        'bookingId': booking.bookingId ?? '',
        'userId': booking.customerId,
        'status': 'accepted',
      },
    );
  }

  Future<void> rejectBooking(BookingModel booking) async {
    if (booking.bookingId == null) return;

    // Update booking status - Cloud Function will automatically process refund
    await BookingDbService.updateStatus(
      booking.bookingId!,
      BookingStatus.rejected,
    );
    await NotificationService.sendNotificationToUser(
      userId: booking.customerId,
      title: 'Booking declined',
      body:
          'Your request for ${booking.serviceTitle} was declined. Your payment will be refunded automatically.',
      type: NotificationType.bookingRejected,
      data: {
        'bookingId': booking.bookingId ?? '',
        'userId': booking.customerId,
        'status': 'rejected',
      },
    );
  }

  Future<void> cancelBooking(BookingModel booking) async {
    if (booking.bookingId == null) return;

    // Update booking status - Cloud Function will automatically process refund
    await BookingDbService.updateStatus(
      booking.bookingId!,
      BookingStatus.canceled,
    );
    if (isProviderView) {
      await NotificationService.sendNotificationToUser(
        userId: booking.customerId,
        title: 'Booking canceled',
        body:
            '${booking.serviceTitle} was canceled by the provider. Your payment will be refunded automatically.',
        type: NotificationType.bookingCanceled,
        data: {
          'bookingId': booking.bookingId ?? '',
          'userId': booking.customerId,
          'status': 'canceled',
        },
      );
    } else {
      await NotificationService.sendNotificationToUser(
        userId: booking.providerId,
        title: 'Customer canceled booking',
        body: 'A customer canceled ${booking.serviceTitle}.',
        type: NotificationType.bookingCanceled,
        data: {
          'bookingId': booking.bookingId ?? '',
          'userId': booking.providerId,
          'status': 'canceled',
        },
      );
      // Also notify customer about refund
      await NotificationService.sendNotificationToUser(
        userId: booking.customerId,
        title: 'Booking canceled',
        body:
            'Your booking for ${booking.serviceTitle} has been canceled. Your payment will be refunded automatically.',
        type: NotificationType.bookingCanceled,
        data: {
          'bookingId': booking.bookingId ?? '',
          'userId': booking.customerId,
          'status': 'canceled',
        },
      );
    }
  }

  void _listenToBookings() {
    final userId = _userId;
    if (userId == null) {
      isLoading.value = false;
      bookings.value = [];
      return;
    }
    isLoading.value = true;
    try {
      _subscription =
          BookingDbService.bookingsForUser(
            userId,
            asProvider: isProviderView,
          ).listen(
            (data) {
              bookings.value = data;
              _autoCancelExpired();
              isLoading.value = false;
            },
            onError: (error) {
              print('Error loading bookings: $error');
              isLoading.value = false;
              bookings.value = [];
            },
            cancelOnError: false,
          );
    } catch (e) {
      print('Error setting up bookings stream: $e');
      isLoading.value = false;
      bookings.value = [];
    }
  }

  Future<void> _autoCancelExpired() async {
    final now = DateTime.now();
    for (final booking in bookings) {
      if (booking.bookingId == null) continue;
      if (booking.status == BookingStatus.requested &&
          booking.startTime.toDate().isBefore(now)) {
        // Update booking status - Cloud Function will automatically process refund
        await BookingDbService.updateStatus(
          booking.bookingId!,
          BookingStatus.canceled,
          extra: {'autoCanceled': true},
        );

        // Notify customer about auto-cancellation and refund
        await NotificationService.sendNotificationToUser(
          userId: booking.customerId,
          title: 'Booking expired',
          body:
              'Your booking request for ${booking.serviceTitle} has expired. Your payment will be refunded automatically.',
          type: NotificationType.bookingCanceled,
          data: {
            'bookingId': booking.bookingId ?? '',
            'userId': booking.customerId,
            'status': 'canceled',
          },
        );
      }
    }
  }

  /// Complete booking by scanning QR code
  Future<void> completeBookingWithQR({
    required BookingModel booking,
    required String verificationToken,
  }) async {
    if (booking.bookingId == null) return;

    try {
      // Validate QR code
      final isValid = await QrCodeService.validateQrCode(
        bookingId: booking.bookingId!,
        verificationToken: verificationToken,
        providerId: booking.providerId,
      );

      if (!isValid) {
        Get.snackbar('Invalid QR Code', 'The QR code is invalid or expired.');
        return;
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

      Get.snackbar('Success', 'Booking marked as completed.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete booking: ${e.toString()}');
    }
  }
}
