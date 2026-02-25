import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/models/booking_slot.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:home_cleaning_app/models/selected_pricing_option.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/controllers/customer_location_controller.dart';
import 'package:home_cleaning_app/services/booking_db_service.dart';
import 'package:home_cleaning_app/services/payments/stripe_payment_service.dart';
import 'package:home_cleaning_app/services/notification_service.dart';

enum BookingPaymentMethod { card, googlePay, applePay }

class ConfirmBookingController extends GetxController {
  ConfirmBookingController({
    required this.service,
    required this.slot,
    required this.selections,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.currency = 'usd',
  });

  final ServiceModel service;
  final BookingSlot slot;
  final List<SelectedPricingOption> selections;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;

  final Rx<BookingPaymentMethod> selectedMethod = BookingPaymentMethod.card.obs;
  final RxBool isProcessing = false.obs;
  final RxString notes = ''.obs;

  String get formattedDay => slot.dayLabel;
  String get formattedTime => slot.timeLabel;
  String get paymentSummaryLabel {
    switch (selectedMethod.value) {
      case BookingPaymentMethod.card:
        return 'Credit / Debit Card';
      case BookingPaymentMethod.googlePay:
        return 'Google Pay';
      case BookingPaymentMethod.applePay:
        return 'Apple Pay';
    }
  }

  List<Map<String, dynamic>> get selectionMaps => selections
      .map(
        (selected) => {
          'optionId': selected.option.optionId,
          'name': selected.option.name,
          'quantity': selected.quantity,
          'unit': selected.option.unitDisplay,
          'unitPrice': selected.option.pricePerUnit,
          'total': selected.total,
        },
      )
      .toList();

  void updateNotes(String value) => notes.value = value;

  void pickPaymentMethod(BookingPaymentMethod method) {
    // The UI already ensures only available payment methods are shown,
    // so we can directly set the selected method without validation
    selectedMethod.value = method;
  }

  Future<void> confirmBooking(BuildContext context) async {
    if (service.serviceId == null) {
      Get.snackbar('Unavailable', 'Service is missing an identifier.');
      return;
    }
    final auth = Get.find<AuthController>();
    final customer = auth.userModel;
    if (customer == null) {
      Get.snackbar('Not logged in', 'Please sign in to continue.');
      return;
    }
    isProcessing.value = true;
    try {
      // The UI ensures only available payment methods can be selected,
      // so we can use the selected method directly
      final paymentResult = await StripePaymentService.payWithTestKey(
        context: context,
        amount: total,
        currency: currency,
        description: service.title ?? 'Home service booking',
        paymentMethod: selectedMethod.value,
      );
      // Get customer location if available
      double? customerLat;
      double? customerLng;
      String? customerAddr;
      if (Get.isRegistered<CustomerLocationController>()) {
        final locationController = Get.find<CustomerLocationController>();
        customerLat = locationController.latitude.value;
        customerLng = locationController.longitude.value;
        customerAddr = locationController.address.value.isNotEmpty
            ? locationController.address.value
            : null;
      }

      final booking = BookingModel(
        serviceId: service.serviceId!,
        serviceTitle: service.title ?? 'Service',
        providerId: service.cleanerId ?? '',
        customerId: customer.uid ?? '',
        providerName: null,
        customerName: customer.displayName,
        serviceThumbnail: (service.images != null && service.images!.isNotEmpty)
            ? service.images!.first
            : null,
        startTime: Timestamp.fromDate(slot.start),
        subtotal: subtotal,
        tax: tax,
        total: total,
        currency: currency,
        status: BookingStatus.requested,
        paymentIntentId: paymentResult.paymentIntentId,
        paymentMethodId: paymentResult.paymentMethodId,
        paymentMethodLabel: paymentSummaryLabel,
        notes: notes.value.trim().isEmpty ? null : notes.value.trim(),
        selections: selectionMaps,
        customerLatitude: customerLat,
        customerLongitude: customerLng,
        customerAddress: customerAddr,
      );
      final bookingId = await BookingDbService.createBooking(booking);
      final providerId = service.cleanerId;
      if (providerId != null && providerId.isNotEmpty) {
        await NotificationService.sendNotificationToUser(
          userId: providerId,
          title: 'New booking request',
          body:
              '${customer.displayName ?? 'A customer'} requested ${service.title ?? 'your service'}.',
          type: NotificationType.bookingRequest,
          data: {
            'bookingId': bookingId,
            'userId': providerId,
            'status': 'requested',
          },
        );
      }
      Get.back(result: bookingId);
      Get.back();
      Get.snackbar('Booked', 'We sent your request to the provider.');
    } catch (e) {
      print(e);
      Get.snackbar('Payment failed', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }
}
