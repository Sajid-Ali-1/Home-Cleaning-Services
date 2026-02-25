import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/service_controller.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/models/service_image_model.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/models/unit_price_option.dart';
import 'package:uuid/uuid.dart';

class CreateServiceFormController extends GetxController {
  final _uuid = Uuid();

  // Stepper state
  RxInt currentStep = 0.obs;
  final int totalSteps = 5;

  // Step 1: Basic Info
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  Rx<ServiceCategory?> selectedCategory = Rx<ServiceCategory?>(
    ServiceCategory.cleaning,
  );

  // Step 2: Pricing
  RxList<UnitPriceOption> pricingOptions = <UnitPriceOption>[].obs;
  RxDouble basePrice = RxDouble(0.0);
  final basePriceController = TextEditingController();
  RxnInt expandedCardIndex = RxnInt(); // Track which pricing card is expanded

  // Step 3: Availability
  Rx<AvailabilitySchedule> availabilitySchedule =
      AvailabilitySchedule.defaultWeek().obs;

  // Step 4: Service Area
  final locationController =
      TextEditingController(); // Service location/address (for display)
  RxnDouble serviceLatitude = RxnDouble(); // Service location latitude
  RxnDouble serviceLongitude = RxnDouble(); // Service location longitude
  RxDouble serviceRadius = 5.0.obs; // Radius in km/miles (default 5)
  RxString radiusUnit = 'km'.obs; // 'km' or 'miles'
  RxBool isGettingLocation = false.obs; // Loading state for location

  // Step 5: Images
  RxList<ServiceImageModel> selectedImages = <ServiceImageModel>[].obs;
  RxInt coverImageIndex = 0.obs;

  // Validation
  RxBool isStep1Valid = false.obs;
  RxBool isStep2Valid = false.obs;
  RxBool isStep3Valid = false.obs;
  RxBool isStep4Valid = false.obs;
  RxBool isStep5Valid = false.obs;

  @override
  void onInit() {
    super.onInit();
    basePriceController.addListener(_onBasePriceChanged);
    // Set default values and validate
    validateStep1();
    _ensurePricingDefaults(selectedCategory.value);
    validateStep3();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    basePriceController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void _onBasePriceChanged() {
    final value = basePriceController.text;
    if (value.isNotEmpty) {
      basePrice.value = double.tryParse(value) ?? 0.0;
    } else {
      basePrice.value = 0.0;
    }
  }

  // Stepper navigation
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  // Step 1: Basic Info
  void setCategory(ServiceCategory? category) {
    selectedCategory.value = category;
    _ensurePricingDefaults(category);
    validateStep1();
  }

  void validateStep1() {
    isStep1Valid.value =
        selectedCategory.value != null &&
        titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  // Step 2: Pricing
  void addPricingOption() {
    // if (selectedCategory.value == ServiceCategory.cleaning &&
    //     pricingOptions.isNotEmpty) {
    //   Get.snackbar(
    //     'Single pricing',
    //     'Cleaning services use one pricing entry.',
    //   );
    //   return;
    // }
    // Collapse all existing cards
    expandedCardIndex.value = null;
    // Add new option
    pricingOptions.add(
      UnitPriceOption(
        optionId: _uuid.v4(),
        name: '',
        pricePerUnit: 0,
        unitName: 'hour',
        unitShortLabel: 'hr',
        minQuantity: 1,
        allowDecimal: false,
      ),
    );
    // Auto-expand the new card (last index)
    expandedCardIndex.value = pricingOptions.length - 1;
    validateStep2();
  }

  void removePricingOption(int index) {
    if (index >= 0 && index < pricingOptions.length) {
      pricingOptions.removeAt(index);
      // Adjust expanded index if needed
      if (expandedCardIndex.value == index) {
        expandedCardIndex.value = null;
      } else if (expandedCardIndex.value != null &&
          expandedCardIndex.value! > index) {
        expandedCardIndex.value = expandedCardIndex.value! - 1;
      }
    }
    validateStep2();
  }

  void toggleCardExpansion(int index) {
    if (expandedCardIndex.value == index) {
      expandedCardIndex.value = null; // Collapse
    } else {
      expandedCardIndex.value = index; // Expand
    }
  }

  void updatePricingOption(int index, UnitPriceOption option) {
    if (index >= 0 && index < pricingOptions.length) {
      pricingOptions[index] = option;
    }
    validateStep2();
  }

  void validateStep2() {
    // At least one pricing option is required for both categories
    final hasValidOptions =
        pricingOptions.isNotEmpty &&
        pricingOptions.every(
          (opt) =>
              opt.pricePerUnit > 0 &&
              opt.unitName.trim().isNotEmpty &&
              opt.name.trim().isNotEmpty,
        );

    // Both categories require at least one valid pricing option
    isStep2Valid.value = hasValidOptions;
  }

  // Step 3: Availability
  List<DailyAvailability> get weeklyAvailability =>
      availabilitySchedule.value.days;

  DailyAvailability getDayAvailability(Weekday day) {
    return availabilitySchedule.value.dayAvailability(day);
  }

  void toggleDayAvailability(Weekday day, bool isEnabled) {
    final updated = getDayAvailability(day).copyWith(isEnabled: isEnabled);
    availabilitySchedule.value = availabilitySchedule.value.copyWithDay(
      updated,
    );
    availabilitySchedule.refresh();
    validateStep3();
  }

  void updateDayTime(Weekday day, {TimeOfDay? start, TimeOfDay? end}) {
    final current = getDayAvailability(day);
    final newStart = start ?? current.startAsTimeOfDay;
    final newEnd = end ?? current.endAsTimeOfDay;
    if (!_isValidRange(newStart, newEnd)) {
      Get.snackbar('Invalid range', 'End time must be after start time.');
      return;
    }
    final updated = current.copyWith(
      startTime: AvailabilitySchedule.formatTimeOfDay(newStart),
      endTime: AvailabilitySchedule.formatTimeOfDay(newEnd),
    );
    availabilitySchedule.value = availabilitySchedule.value.copyWithDay(
      updated,
    );
    availabilitySchedule.refresh();
    validateStep3();
  }

  void copyDayToTargets(Weekday source, List<Weekday> targets) {
    final template = getDayAvailability(source);
    availabilitySchedule.value = availabilitySchedule.value.applyToDays(
      template,
      targets,
    );
    availabilitySchedule.refresh();
    validateStep3();
  }

  void resetAvailabilityToDefault() {
    availabilitySchedule.value = AvailabilitySchedule.defaultWeek();
    availabilitySchedule.refresh();
    validateStep3();
  }

  void clearAvailability() {
    availabilitySchedule.value = AvailabilitySchedule(
      days: Weekday.values
          .map((day) => DailyAvailability(day: day, isEnabled: false))
          .toList(),
    );
    availabilitySchedule.refresh();
    validateStep3();
  }

  void validateStep3() {
    isStep3Valid.value = availabilitySchedule.value.hasAvailability;
  }

  bool _isValidRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  // Step 4: Service Area
  void setServiceRadius(double radius) {
    serviceRadius.value = radius;
    validateStep4();
  }

  void setRadiusUnit(String unit) {
    radiusUnit.value = unit;
  }

  void validateStep4() {
    isStep4Valid.value =
        serviceLatitude.value != null &&
        serviceLongitude.value != null &&
        locationController.text.trim().isNotEmpty &&
        serviceRadius.value >= 1.0;
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      isGettingLocation.value = true;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isGettingLocation.value = false;
        Get.snackbar(
          'Location Disabled',
          'Please enable location services in your device settings.',
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isGettingLocation.value = false;
          Get.snackbar(
            'Permission Denied',
            'Location permissions are required to set your service location.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isGettingLocation.value = false;
        Get.snackbar(
          'Permission Denied',
          'Location permissions are permanently denied. Please enable them in settings.',
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = _formatAddress(place);
          setLocationCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
          );
        } else {
          setLocationCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
            address:
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          );
        }
      } catch (e) {
        // If geocoding fails, still set coordinates
        setLocationCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          address:
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        );
      }

      isGettingLocation.value = false;
    } catch (e) {
      isGettingLocation.value = false;
      Get.snackbar('Error', 'Failed to get location: ${e.toString()}');
    }
  }

  Future<void> setLocationFromMap({
    required double latitude,
    required double longitude,
  }) async {
    try {
      isGettingLocation.value = true;
      String address;
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        address = placemarks.isNotEmpty
            ? _formatAddress(placemarks.first)
            : '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      } catch (e) {
        address =
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      }
      setLocationCoordinates(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Format address from placemark
  String _formatAddress(Placemark place) {
    final parts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  // Set location coordinates
  void setLocationCoordinates({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    serviceLatitude.value = latitude;
    serviceLongitude.value = longitude;
    if (address != null && address.isNotEmpty) {
      locationController.text = address;
    }
    validateStep4();
  }

  // Clear location
  void clearLocation() {
    serviceLatitude.value = null;
    serviceLongitude.value = null;
    locationController.clear();
    validateStep4();
  }

  // Step 5: Images
  void addImages(List<File> images) {
    final newImages = images
        .map((file) => ServiceImageModel.fromFile(file))
        .toList();
    selectedImages.addAll(newImages);
    if (selectedImages.length == 1) {
      coverImageIndex.value = 0;
    }
    validateStep5();
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      // Adjust cover index if needed
      if (coverImageIndex.value >= selectedImages.length &&
          selectedImages.isNotEmpty) {
        coverImageIndex.value = 0;
      } else if (coverImageIndex.value > index && selectedImages.isNotEmpty) {
        coverImageIndex.value--;
      }
    }
    validateStep5();
  }

  void setCoverImage(int index) {
    if (index < 0 || index >= selectedImages.length) return;

    // If it's already the cover image, no need to change anything
    if (index == coverImageIndex.value) return;

    // Move the tapped image to the front of the list
    final image = selectedImages.removeAt(index);
    selectedImages.insert(0, image);

    // Update cover index to point to the first image
    coverImageIndex.value = 0;

    // Ensure UI updates correctly
    selectedImages.refresh();
  }

  void validateStep5() {
    isStep5Valid.value =
        selectedImages.isNotEmpty && selectedImages.length <= 10;
  }

  // Get list of File objects for upload (only new images)
  List<File> getNewImageFiles() {
    return selectedImages
        .where((img) => !img.isExisting && img.file != null)
        .map((img) => img.file!)
        .toList();
  }

  // Get list of URLs to delete (removed existing images)
  List<String> getRemovedImageUrls(List<String>? originalUrls) {
    if (originalUrls == null || originalUrls.isEmpty) return [];

    final currentUrls = selectedImages
        .where((img) => img.isExisting && img.url != null)
        .map((img) => img.url!)
        .toList();

    return originalUrls.where((url) => !currentUrls.contains(url)).toList();
  }

  // Load existing service data
  void loadServiceData(ServiceModel service) {
    titleController.text = service.title ?? '';
    descriptionController.text = service.description ?? '';
    selectedCategory.value = service.serviceCategory;
    pricingOptions.value = service.pricingOptions ?? [];
    _ensurePricingDefaults(service.serviceCategory);
    basePrice.value = service.basePrice ?? 0.0;
    if (basePrice.value > 0) {
      basePriceController.text = basePrice.value.toStringAsFixed(2);
    }
    // Load availability
    if (service.availabilitySchedule != null) {
      availabilitySchedule.value = service.availabilitySchedule!;
    } else if (service.availabilitySchedule == null &&
        service.serviceArea != null) {
      availabilitySchedule.value = AvailabilitySchedule.defaultWeek();
    }
    validateStep3();

    // Load service area data
    if (service.serviceArea != null) {
      // Load coordinates
      final lat = service.serviceArea!['latitude'] as num?;
      final lng = service.serviceArea!['longitude'] as num?;
      if (lat != null && lng != null) {
        serviceLatitude.value = lat.toDouble();
        serviceLongitude.value = lng.toDouble();
      }

      // Load address/location text
      final location = service.serviceArea!['location'] as String?;
      if (location != null && location.isNotEmpty) {
        locationController.text = location;
      } else if (lat != null && lng != null) {
        // Fallback: show coordinates if no address
        locationController.text =
            '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      } else {
        // Fallback: if old format with areas, use first area as location
        final areas = service.serviceArea!['areas'] as List<dynamic>?;
        if (areas != null && areas.isNotEmpty) {
          locationController.text = areas.first.toString();
        }
      }

      serviceRadius.value =
          (service.serviceArea!['radius'] as num?)?.toDouble() ?? 5.0;
      radiusUnit.value = service.serviceArea!['radiusUnit'] as String? ?? 'km';
    } else if (service.location != null && service.location!.isNotEmpty) {
      // Fallback to location field if serviceArea is null
      locationController.text = service.location!;
    }

    // Load existing images
    selectedImages.clear();
    if (service.images != null && service.images!.isNotEmpty) {
      selectedImages.value = service.images!
          .map((url) => ServiceImageModel.fromUrl(url))
          .toList();
      coverImageIndex.value = 0; // First image is cover by default
    }

    validateStep1();
    validateStep2();
    validateStep3();
    validateStep4();
    validateStep5();
  }

  void _ensurePricingDefaults(ServiceCategory? category) {
    // Only enforce cleaning category restriction (max 1 option)
    // Do not automatically add pricing options - let validation handle the requirement
    if (category == ServiceCategory.cleaning && pricingOptions.length > 1) {
      pricingOptions.value = [pricingOptions.first];
    }
    // Validation will ensure at least one pricing option is required for both categories
  }

  // Build service model from form data
  ServiceModel buildServiceModel({String? serviceId, String? cleanerId}) {
    // Build location string from location and radius
    String location = '';
    if (locationController.text.trim().isNotEmpty) {
      location =
          '${locationController.text.trim()} (${serviceRadius.value.toStringAsFixed(1)} ${radiusUnit.value})';
    }

    return ServiceModel(
      serviceId: serviceId,
      cleanerId: cleanerId,
      serviceCategory: selectedCategory.value,
      serviceType: null, // ServiceType is deprecated
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      pricingOptions: pricingOptions.isEmpty ? null : pricingOptions.toList(),
      basePrice: basePrice.value > 0 ? basePrice.value : null,
      location: location.isEmpty ? null : location,
      images: null, // Will be set after upload
      isActive: true,
      availabilitySchedule: getAvailabilityData(),
    );
  }

  // Get service area data for storage
  Map<String, dynamic> getServiceAreaData() {
    return {
      'latitude': serviceLatitude.value,
      'longitude': serviceLongitude.value,
      'location': locationController.text.trim(), // Address for display
      'radius': serviceRadius.value,
      'radiusUnit': radiusUnit.value,
    };
  }

  AvailabilitySchedule? getAvailabilityData() {
    return availabilitySchedule.value.hasAvailability
        ? availabilitySchedule.value
        : null;
  }

  // Validate current step
  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        validateStep1();
        return isStep1Valid.value;
      case 1:
        validateStep2();
        return isStep2Valid.value;
      case 2:
        validateStep3();
        return isStep3Valid.value;
      case 3:
        validateStep4();
        return isStep4Valid.value;
      case 4:
        validateStep5();
        return isStep5Valid.value;
      default:
        return false;
    }
  }

  // Get final image URLs list (reordered with cover first)
  List<String> getFinalImageUrls() {
    final images = List<ServiceImageModel>.from(selectedImages);

    // Reorder so cover image is first
    if (images.isNotEmpty && coverImageIndex.value < images.length) {
      final coverImage = images.removeAt(coverImageIndex.value);
      images.insert(0, coverImage);
    }

    // Convert to URLs
    return images
        .map((img) {
          if (img.isExisting && img.url != null) {
            return img.url!;
          }
          // For new images, return placeholder (will be replaced after upload)
          return '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }

  // Pick images from device
  Future<void> pickImages() async {
    try {
      final imagePicker = ImagePicker();
      final List<XFile> images = await imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        addImages(images.map((xFile) => File(xFile.path)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: ${e.toString()}');
    }
  }

  // Save service (create or update)
  Future<bool> saveService({
    required ServiceController serviceController,
    required AuthController authController,
    ServiceModel? existingService,
  }) async {
    final cleanerId = authController.userModel?.uid;
    if (cleanerId == null) {
      Get.snackbar('Error', 'User not authenticated');
      return false;
    }

    // Build service model
    final serviceModel = buildServiceModel(
      serviceId: existingService?.serviceId,
      cleanerId: cleanerId,
    );

    // Add service area data
    serviceModel.serviceArea = getServiceAreaData();
    serviceModel.availabilitySchedule = getAvailabilityData();

    // Handle images
    // Get new image files for upload
    final newImageFiles = getNewImageFiles();
    List<String> uploadedUrls = [];

    if (newImageFiles.isNotEmpty) {
      serviceController.selectedImageFiles.value = newImageFiles;
      uploadedUrls = await serviceController.uploadImages(
        cleanerId: cleanerId,
        serviceId: existingService?.serviceId,
      );
    }

    // Build final image list maintaining order, replacing new files with uploaded URLs
    List<String> finalImageUrls = [];
    int newImageIndex = 0;

    for (var img in selectedImages) {
      if (img.isExisting && img.url != null) {
        finalImageUrls.add(img.url!);
      } else if (img.file != null && newImageIndex < uploadedUrls.length) {
        finalImageUrls.add(uploadedUrls[newImageIndex]);
        newImageIndex++;
      }
    }

    // Reorder so cover image is first
    if (finalImageUrls.isNotEmpty &&
        coverImageIndex.value < selectedImages.length &&
        coverImageIndex.value < finalImageUrls.length) {
      final coverUrl = finalImageUrls[coverImageIndex.value];
      finalImageUrls.removeAt(coverImageIndex.value);
      finalImageUrls.insert(0, coverUrl);
    }

    serviceModel.images = finalImageUrls;

    // Save service
    bool success;
    if (existingService != null) {
      success = await serviceController.updateService(
        service: serviceModel,
        cleanerId: cleanerId,
      );
    } else {
      success = await serviceController.createService(
        service: serviceModel,
        cleanerId: cleanerId,
      );
    }

    return success;
  }
}
