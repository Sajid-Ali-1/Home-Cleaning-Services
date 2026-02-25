import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/confirm_booking_controller.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/models/booking_slot.dart';
import 'package:home_cleaning_app/models/selected_pricing_option.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/models/unit_price_option.dart';
import 'package:home_cleaning_app/services/booking_db_service.dart';
import 'package:home_cleaning_app/services/service_db_services.dart';
import 'package:home_cleaning_app/views/screens/booking/confirm_booking_screen.dart';
import 'package:home_cleaning_app/views/screens/chat/chat_screen.dart';

class ServiceDetailsController extends GetxController {
  ServiceDetailsController({required this.service});

  // Current service
  final ServiceModel service;
  Rx<ServiceModel?> currentService = Rx<ServiceModel?>(null);
  RxBool isLoading = false.obs;

  // Booking state (for customers)
  RxString selectedDate = ''.obs;
  RxString selectedTime = ''.obs;
  RxBool isBooking = false.obs;

  // Pricing selections
  RxMap<String, double> selectedOptionQuantities = <String, double>{}.obs;

  // Pricing calculations
  RxDouble servicesSubtotal = 0.0.obs;
  RxDouble taxesAndFees = 0.0.obs;
  RxDouble totalPrice = 0.0.obs;
  final double taxRate = 0.07;
  static const int _slotIntervalMinutes = 60;

  // Image gallery
  RxInt currentImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadServiceDetails();
    _ensureDefaultSelections(currentService.value ?? service);
    calculatePricing();
    ensureInitialSlotSelection();
  }

  /// Load service details
  Future<void> loadServiceDetails() async {
    if (service.serviceId == null) {
      currentService.value = service;
      _ensureDefaultSelections(service);
      ensureInitialSlotSelection();
      return;
    }

    try {
      isLoading.value = true;
      currentService.value = await ServiceDbServices.getServiceById(
        service.serviceId!,
      );
      currentService.value ??= service;
      _ensureDefaultSelections(currentService.value ?? service);
      calculatePricing();
      ensureInitialSlotSelection();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load service details: ${e.toString()}');
      currentService.value = service;
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate pricing based on selected options and base price
  void calculatePricing() {
    final serviceData = currentService.value ?? service;
    final pricingOptions = serviceData.pricingOptions ?? [];
    double subtotal = 0.0;

    for (final entry in selectedOptionQuantities.entries) {
      final option = _findOptionById(pricingOptions, entry.key);
      if (option == null) continue;
      subtotal += option.calculateTotal(entry.value);
    }

    if (serviceData.basePrice != null && serviceData.basePrice! > 0) {
      subtotal += serviceData.basePrice!;
    }

    servicesSubtotal.value = subtotal;
    taxesAndFees.value = subtotal > 0 ? subtotal * taxRate : 0.0;
    totalPrice.value = subtotal + taxesAndFees.value;
  }

  /// Toggle option on/off
  void toggleOption(UnitPriceOption option) {
    final serviceData = currentService.value ?? service;
    final isLandscaping =
        serviceData.serviceCategory == ServiceCategory.landscaping;
    if (!isLandscaping) {
      selectedOptionQuantities.value = {
        option.optionId: option.minQuantity > 0 ? option.minQuantity : 1.0,
      };
    } else if (selectedOptionQuantities.containsKey(option.optionId)) {
      selectedOptionQuantities.remove(option.optionId);
    } else {
      selectedOptionQuantities[option.optionId] = option.minQuantity > 0
          ? option.minQuantity
          : 1.0;
    }
    calculatePricing();
  }

  /// Adjust option quantity
  void updateQuantity(UnitPriceOption option, double quantity) {
    final serviceData = currentService.value ?? service;
    final isLandscaping =
        serviceData.serviceCategory == ServiceCategory.landscaping;
    if (quantity <= 0) {
      if (isLandscaping) {
        selectedOptionQuantities.remove(option.optionId);
      } else {
        selectedOptionQuantities[option.optionId] = option.minQuantity > 0
            ? option.minQuantity
            : 1.0;
      }
    } else {
      selectedOptionQuantities[option.optionId] = _clampQuantity(
        option,
        quantity,
      );
    }
    calculatePricing();
  }

  void incrementQuantity(UnitPriceOption option) {
    final current = getQuantityForOption(option);
    updateQuantity(option, current + option.quantityStep);
  }

  void decrementQuantity(UnitPriceOption option) {
    final current = getQuantityForOption(option);
    updateQuantity(option, current - option.quantityStep);
  }

  bool isOptionSelected(UnitPriceOption option) {
    return selectedOptionQuantities.containsKey(option.optionId);
  }

  double getQuantityForOption(UnitPriceOption option) {
    return selectedOptionQuantities[option.optionId] ??
        (option.minQuantity > 0 ? option.minQuantity : 1.0);
  }

  AvailabilitySchedule? get availabilitySchedule =>
      (currentService.value ?? service).availabilitySchedule;

  List<DailyAvailability> get availabilityDays =>
      availabilitySchedule?.days ?? [];

  bool get hasAvailability => availabilitySchedule?.hasAvailability ?? false;

  Weekday get today => Weekday.values[DateTime.now().weekday - 1];

  String formatRange(DailyAvailability day) {
    return '${_formatTime(day.startTime)} - ${_formatTime(day.endTime)}';
  }

  bool isDayOpen(DailyAvailability day) => day.isEnabled && day.hasValidRange();

  List<AvailabilitySlotView> get allAvailabilitySlots =>
      _generateAvailabilitySlots(maxItems: 60);

  List<AvailabilityDayGroup> get availabilityDayGroups =>
      _groupAvailabilitySlots();

  bool get isTimeSelected =>
      selectedDate.value.isNotEmpty && selectedTime.value.isNotEmpty;

  bool get canBook => isTimeSelected && hasSelections && !isBooking.value;

  AvailabilitySlotView? get selectedAvailabilitySlot {
    if (!isTimeSelected) return null;
    for (final slot in allAvailabilitySlots) {
      if (slot.dateKey == selectedDate.value &&
          slot.startRaw == selectedTime.value) {
        return slot;
      }
    }
    return null;
  }

  BookingSlot? get selectedSlotInfo {
    final slot = selectedAvailabilitySlot;
    if (slot == null) return null;
    return BookingSlot(start: slot.startDateTime);
  }

  void selectAvailabilitySlot(AvailabilitySlotView slot) {
    selectedDate.value = slot.dateKey;
    selectedTime.value = slot.startRaw;
  }

  void ensureInitialSlotSelection() {
    if (selectedDate.value.isNotEmpty && selectedTime.value.isNotEmpty) {
      return;
    }
    final firstSlot = allAvailabilitySlots.isNotEmpty
        ? allAvailabilitySlots.first
        : null;
    if (firstSlot != null) {
      selectedDate.value = firstSlot.dateKey;
      selectedTime.value = firstSlot.startRaw;
    }
  }

  /// Book service (placeholder - can be replaced with actual booking logic)
  Future<bool> bookService() async {
    if (selectedDate.value.isEmpty || selectedTime.value.isEmpty) {
      Get.snackbar('Error', 'Please select a date and time');
      return false;
    }

    if (!hasSelections) {
      Get.snackbar(
        'Selection Required',
        'Please select at least one pricing option or quantity.',
      );
      return false;
    }

    final slot = selectedSlotInfo;
    if (slot == null) {
      Get.snackbar('Error', 'Unable to read the selected slot.');
      return false;
    }

    final serviceData = currentService.value ?? service;
    final subtotal = servicesSubtotal.value;
    final tax = taxesAndFees.value;
    final total = totalPrice.value;

    try {
      isBooking.value = true;
      await Get.to(
        () => const ConfirmBookingScreen(),
        binding: BindingsBuilder(() {
          Get.put(
            ConfirmBookingController(
              service: serviceData,
              slot: slot,
              selections: selectedPricingOptions,
              subtotal: subtotal,
              tax: tax,
              total: total,
            ),
          );
        }),
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to book service: ${e.toString()}');
      return false;
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> openChatWithProvider() async {
    final auth = Get.find<AuthController>();
    final userId = auth.userModel?.uid;
    if (userId == null) {
      Get.snackbar('Login required', 'Please sign in to start a chat.');
      return;
    }
    final serviceId = (currentService.value ?? service).serviceId;
    if (serviceId == null) {
      Get.snackbar('Unavailable', 'Service info missing.');
      return;
    }
    final booking = await BookingDbService.getLatestBookingForService(
      serviceId: serviceId,
      customerId: userId,
    );
    if (booking == null || booking.bookingId == null) {
      Get.snackbar(
        'No booking yet',
        'Book this service first to start chatting with the provider.',
      );
      return;
    }
    Get.to(() => ChatScreen(booking: booking, isProviderView: false));
  }

  /// Check if current user owns this service
  bool isServiceOwner(String? currentUserId) {
    return currentService.value?.cleanerId == currentUserId ||
        service.cleanerId == currentUserId;
  }

  /// Get service location display text
  String getServiceLocationText() {
    final serviceData = currentService.value ?? service;
    if (serviceData.serviceArea != null) {
      final location = serviceData.serviceArea!['location'] as String?;
      final radius = serviceData.serviceArea!['radius'] as num?;
      final radiusUnit =
          serviceData.serviceArea!['radiusUnit'] as String? ?? 'km';
      if (location != null && location.isNotEmpty) {
        if (radius != null && radius > 0) {
          return '$location (${radius.toStringAsFixed(1)} $radiusUnit radius)';
        }
        return location;
      }
    }
    return serviceData.location ?? 'Location not specified';
  }

  /// Get service area info
  Map<String, dynamic>? getServiceAreaInfo() {
    return currentService.value?.serviceArea ?? service.serviceArea;
  }

  List<SelectedPricingOption> get selectedPricingOptions {
    final serviceData = currentService.value ?? service;
    final options = serviceData.pricingOptions ?? [];
    final selections = <SelectedPricingOption>[];

    for (final entry in selectedOptionQuantities.entries) {
      final option = _findOptionById(options, entry.key);
      if (option == null) continue;
      selections.add(
        SelectedPricingOption(option: option, quantity: entry.value),
      );
    }

    return selections;
  }

  bool get hasSelections {
    final serviceData = currentService.value ?? service;
    final hasBasePrice = (serviceData.basePrice ?? 0) > 0;
    return selectedPricingOptions.isNotEmpty || hasBasePrice;
  }

  /// Navigate to image at index
  void goToImage(int index) {
    final serviceData = currentService.value ?? service;
    if (serviceData.images != null &&
        index >= 0 &&
        index < serviceData.images!.length) {
      currentImageIndex.value = index;
    }
  }

  /// Get next image
  void nextImage() {
    final serviceData = currentService.value ?? service;
    if (serviceData.images != null && serviceData.images!.isNotEmpty) {
      currentImageIndex.value =
          (currentImageIndex.value + 1) % serviceData.images!.length;
    }
  }

  /// Get previous image
  void previousImage() {
    final serviceData = currentService.value ?? service;
    if (serviceData.images != null && serviceData.images!.isNotEmpty) {
      currentImageIndex.value = currentImageIndex.value == 0
          ? serviceData.images!.length - 1
          : currentImageIndex.value - 1;
    }
  }

  void _ensureDefaultSelections(ServiceModel serviceData) {
    final isCleaning = serviceData.serviceCategory == ServiceCategory.cleaning;
    if (!isCleaning) return;
    final option = serviceData.pricingOptions?.first;
    if (option == null) return;
    final qty = option.minQuantity > 0 ? option.minQuantity : 1.0;
    selectedOptionQuantities.value = {option.optionId: qty};
  }

  UnitPriceOption? _findOptionById(
    List<UnitPriceOption>? options,
    String optionId,
  ) {
    if (options == null) return null;
    for (final option in options) {
      if (option.optionId == optionId) {
        return option;
      }
    }
    return null;
  }

  double _clampQuantity(UnitPriceOption option, double quantity) {
    double value = quantity;
    if (!option.allowDecimal) {
      value = value.roundToDouble();
    }
    if (value < option.minQuantity) {
      value = option.minQuantity;
    }
    if (option.maxQuantity != null && value > option.maxQuantity!) {
      value = option.maxQuantity!;
    }
    if (value <= 0) {
      value = option.minQuantity > 0 ? option.minQuantity : 1.0;
    }
    return value;
  }

  List<AvailabilitySlotView> _generateAvailabilitySlots({int maxItems = 8}) {
    final schedule = availabilitySchedule;
    if (schedule == null) return [];
    final List<AvailabilitySlotView> slots = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (int offset = 0; offset < 30 && slots.length < maxItems; offset++) {
      final date = today.add(Duration(days: offset));
      final weekday = Weekday.values[date.weekday - 1];
      final dayAvailability = schedule.dayAvailability(weekday);
      if (!dayAvailability.isEnabled || !dayAvailability.hasValidRange()) {
        continue;
      }
      final dayStart = _combineDateWithTime(date, dayAvailability.startTime);
      final dayEnd = _combineDateWithTime(date, dayAvailability.endTime);
      if (dayStart == null || dayEnd == null) continue;
      var pointer = dayStart;
      if (_isSameDay(date, now)) {
        final currentTime = DateTime(
          date.year,
          date.month,
          date.day,
          now.hour,
          now.minute,
        );
        if (pointer.isBefore(currentTime)) {
          final diffMinutes = currentTime.difference(pointer).inMinutes;
          final steps = (diffMinutes / _slotIntervalMinutes).ceil();
          pointer = pointer.add(
            Duration(minutes: steps * _slotIntervalMinutes),
          );
        }
      }
      while (pointer.isBefore(dayEnd) && slots.length < maxItems) {
        final chipLabel =
            '${_formatSlotDayLabel(offset, date)} (${_formatTimeFromDate(pointer)})';
        slots.add(
          AvailabilitySlotView(
            date: date,
            dateKey: _dateKey(date),
            startRaw: _formatRawTime(pointer),
            chipLabel: chipLabel,
            timeLabel: _formatTimeFromDate(pointer),
            startDateTime: pointer,
          ),
        );
        pointer = pointer.add(Duration(minutes: _slotIntervalMinutes));
      }
    }
    return slots;
  }

  List<AvailabilityDayGroup> _groupAvailabilitySlots() {
    final Map<String, AvailabilityDayGroup> grouped = {};
    for (final slot in allAvailabilitySlots) {
      if (grouped.containsKey(slot.dateKey)) {
        grouped[slot.dateKey]!.slots.add(slot);
      } else {
        grouped[slot.dateKey] = AvailabilityDayGroup(
          date: slot.date,
          slots: [slot],
        );
      }
    }
    final list = grouped.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  DateTime? _combineDateWithTime(DateTime date, String timeValue) {
    final parts = timeValue.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatSlotDayLabel(int offset, DateTime date) {
    if (offset == 0) return 'Today';
    if (offset == 1) return 'Tomorrow';
    final weekday = _weekdayLabels[date.weekday - 1];
    final month = _monthLabels[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  String _dateKey(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return value;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    final minuteLabel = minute.toString().padLeft(2, '0');
    return '$hour:$minuteLabel $period';
  }

  String _formatRawTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeFromDate(DateTime value) {
    return _formatTime(_formatRawTime(value));
  }
}

class AvailabilitySlotView {
  AvailabilitySlotView({
    required this.date,
    required this.dateKey,
    required this.startRaw,
    required this.chipLabel,
    required this.timeLabel,
    required this.startDateTime,
  });

  final DateTime date;
  final String dateKey;
  final String startRaw;
  final String chipLabel;
  final String timeLabel;
  final DateTime startDateTime;

  String get selectionKey => '${dateKey}_$startRaw';
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class AvailabilityDayGroup {
  AvailabilityDayGroup({required this.date, required this.slots});

  final DateTime date;
  final List<AvailabilitySlotView> slots;

  String get dateKey {
    if (slots.isNotEmpty) {
      return slots.first.dateKey;
    }
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
