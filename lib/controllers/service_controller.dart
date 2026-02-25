import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/customer_location_controller.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/services/service_db_services.dart';
import 'package:home_cleaning_app/services/storage_services.dart';
import 'package:home_cleaning_app/services/db_services.dart';
import 'package:home_cleaning_app/utils/service_validators.dart';
import 'package:home_cleaning_app/utils/location_utils.dart';

class ServiceController extends GetxController {
  // Services list
  RxList<ServiceModel> allServices = <ServiceModel>[].obs;
  RxList<ServiceModel> filteredServices = <ServiceModel>[].obs;
  RxList<ServiceModel> myServices = <ServiceModel>[].obs;

  // Loading state
  RxBool isLoading = true.obs;

  // View mode (list/grid) - default to list view
  RxBool isListView = true.obs;

  // Check if current user is a cleaner
  bool get isCleanerMode {
    try {
      final authController = Get.find<AuthController>();
      return authController.userModel?.userType == UserType.cleaner;
    } catch (e) {
      return false;
    }
  }

  // Get current user ID
  String? get currentUserId {
    try {
      final authController = Get.find<AuthController>();
      return authController.userModel?.uid;
    } catch (e) {
      return null;
    }
  }

  // Get the appropriate services list based on user type
  RxList<ServiceModel> get currentServicesList {
    return isCleanerMode ? myServices : allServices;
  }

  // Filter states
  Rx<ServiceCategory?> selectedCategory = Rx<ServiceCategory?>(null);
  Rx<String?> selectedLocation = Rx<String?>(null);
  Rx<double?> minPrice = Rx<double?>(null);
  Rx<double?> maxPrice = Rx<double?>(null);
  RxString searchQuery = ''.obs;
  RxBool isSearching = false.obs;

  // Form state
  RxBool isCreatingService = false.obs;
  RxBool isUploadingImages = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  // Current service being created/edited
  ServiceModel? currentService;
  RxList<File> selectedImageFiles = <File>[].obs;
  RxList<String> uploadedImageUrls = <String>[].obs;

  // Search debounce timer
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    initializeServices();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    super.onClose();
  }

  /// Initialize services based on user type
  Future<void> initializeServices() async {
    if (isCleanerMode && currentUserId != null) {
      await loadMyServices(currentUserId!);
    } else {
      await loadAllServices();
    }
  }

  /// Load all active services (for customers)
  Future<void> loadAllServices() async {
    try {
      isLoading.value = true;
      allServices.value = await ServiceDbServices.getAllActiveServices();
      applyFilters();
      // Add small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load services for current cleaner
  Future<void> loadMyServices(String cleanerId) async {
    try {
      isLoading.value = true;
      myServices.value = await ServiceDbServices.getServicesByCleaner(
        cleanerId,
      );
      applyFilters();
      // Add small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load your services: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Stream services for real-time updates
  void streamServices() {
    ServiceDbServices.streamActiveServices().listen((services) {
      allServices.value = services;
      applyFilters();
    });
  }

  /// Stream my services for real-time updates
  void streamMyServices(String cleanerId) {
    ServiceDbServices.streamServicesByCleaner(cleanerId).listen((services) {
      myServices.value = services;
    });
  }

  /// Toggle view mode (list/grid)
  void toggleViewMode() {
    isListView.value = !isListView.value;
  }

  /// Apply filters to services (uses appropriate list based on user type)
  void applyFilters() {
    // Use myServices for cleaners, allServices for customers
    final sourceList = isCleanerMode ? myServices : allServices;
    filteredServices.value = List<ServiceModel>.from(sourceList);

    // Location-based radius filter (only for customers)
    if (!isCleanerMode) {
      try {
        final locationController = Get.find<CustomerLocationController>();
        if (locationController.hasLocation.value &&
            locationController.latitude.value != null &&
            locationController.longitude.value != null) {
          final customerLat = locationController.latitude.value!;
          final customerLon = locationController.longitude.value!;

          filteredServices.value = filteredServices.where((service) {
            // Check if service has serviceArea data
            if (service.serviceArea == null) {
              // If no serviceArea, show the service (fallback behavior)
              return true;
            }

            final serviceArea = service.serviceArea!;
            final serviceLat = serviceArea['latitude'] as num?;
            final serviceLon = serviceArea['longitude'] as num?;
            final radius = serviceArea['radius'] as num?;
            final radiusUnit = serviceArea['radiusUnit'] as String?;

            // If service doesn't have complete location data, show it
            if (serviceLat == null ||
                serviceLon == null ||
                radius == null ||
                radiusUnit == null) {
              return true;
            }

            // Check if customer is within service radius
            return isCustomerWithinServiceRadius(
              customerLat: customerLat,
              customerLon: customerLon,
              serviceLat: serviceLat.toDouble(),
              serviceLon: serviceLon.toDouble(),
              radius: radius.toDouble(),
              radiusUnit: radiusUnit,
            );
          }).toList();
        }
      } catch (e) {
        // If CustomerLocationController is not initialized, continue without location filter
        // This can happen if the controller hasn't been initialized yet
      }
    }

    // Category filter
    if (selectedCategory.value != null) {
      filteredServices.value = filteredServices
          .where((service) => service.serviceCategory == selectedCategory.value)
          .toList();
    }

    // Legacy location text filter (deprecated, kept for backward compatibility)
    String? locationValue = selectedLocation.value;
    if (locationValue != null && locationValue.isNotEmpty) {
      String searchLocation = locationValue.toLowerCase();
      filteredServices.value = filteredServices
          .where(
            (service) =>
                service.location?.toLowerCase().contains(searchLocation) ??
                false,
          )
          .toList();
    }

    // Price range filter
    if (minPrice.value != null || maxPrice.value != null) {
      filteredServices.value = filteredServices.where((service) {
        double? serviceMinPrice = service.getMinPrice();
        if (serviceMinPrice == null) return false;

        if (minPrice.value != null && serviceMinPrice < minPrice.value!) {
          return false;
        }
        if (maxPrice.value != null && serviceMinPrice > maxPrice.value!) {
          return false;
        }
        return true;
      }).toList();
    }

    // Search query filter
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      filteredServices.value = filteredServices
          .where(
            (service) =>
                (service.title?.toLowerCase().contains(query) ?? false) ||
                (service.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }
  }

  /// Clear all filters
  void clearFilters() {
    selectedCategory.value = null;
    selectedLocation.value = null;
    minPrice.value = null;
    maxPrice.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  /// Set category filter
  void setCategoryFilter(ServiceCategory? category) {
    selectedCategory.value = category;
    applyFilters();
  }

  /// Set location filter
  void setLocationFilter(String? location) {
    selectedLocation.value = location;
    applyFilters();
  }

  /// Set price range filter
  void setPriceRangeFilter(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    applyFilters();
  }

  /// Set search query with debounce
  void setSearchQuery(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Show loading immediately
    isSearching.value = true;

    // Update query immediately for UI feedback
    searchQuery.value = query;

    // Debounce the actual filtering
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      applyFilters();
      isSearching.value = false;
    });
  }

  /// Check if cleaner is verified before creating service
  Future<bool> checkCleanerVerification(String cleanerId) async {
    try {
      return await DbServices.isCleanerVerified(cleanerId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify cleaner status: ${e.toString()}');
      return false;
    }
  }

  /// Upload service images
  Future<List<String>> uploadImages({
    required String cleanerId,
    String? serviceId,
  }) async {
    try {
      isUploadingImages.value = true;
      uploadProgress.value = 0.0;

      List<String> urls = await StorageServices.uploadMultipleServiceImages(
        imageFiles: selectedImageFiles,
        cleanerId: cleanerId,
        serviceId: serviceId,
      );

      uploadedImageUrls.addAll(urls);
      uploadProgress.value = 1.0;
      isUploadingImages.value = false;

      return urls;
    } catch (e) {
      isUploadingImages.value = false;
      Get.snackbar('Error', 'Failed to upload images: ${e.toString()}');
      rethrow;
    }
  }

  /// Create a new service
  Future<bool> createService({
    required ServiceModel service,
    required String cleanerId,
  }) async {
    try {
      // Check verification
      bool isVerified = await checkCleanerVerification(cleanerId);
      if (!isVerified) {
        Get.snackbar(
          'Verification Required',
          'Your account must be verified by admin before creating services',
        );
        return false;
      }

      // Validate service
      // String? validationError = _validateService(service);
      // if (validationError != null) {
      //   Get.snackbar('Validation Error', validationError);
      //   return false;
      // }

      isCreatingService.value = true;

      // Set cleaner ID
      service.cleanerId = cleanerId;

      // Create service in Firestore first to get serviceId
      String serviceId = await ServiceDbServices.addService(service);
      service.serviceId = serviceId;

      // Upload images with serviceId (organized by service)
      if (selectedImageFiles.isNotEmpty) {
        List<String> imageUrls = await uploadImages(
          cleanerId: cleanerId,
          serviceId: serviceId,
        );
        service.images = imageUrls;

        // Update service with image URLs
        await ServiceDbServices.updateService(service);
      }

      isCreatingService.value = false;

      // Reset form
      selectedImageFiles.clear();
      uploadedImageUrls.clear();
      currentService = null;

      // Get.snackbar('Success', 'Service created successfully');
      // Reload appropriate services based on user type
      if (isCleanerMode && currentUserId != null) {
        await loadMyServices(currentUserId!);
      } else {
        await loadAllServices();
      }
      return true;
    } catch (e) {
      isCreatingService.value = false;
      Get.snackbar('Error', 'Failed to create service: ${e.toString()}');
      return false;
    }
  }

  /// Update an existing service
  Future<bool> updateService({
    required ServiceModel service,
    required String cleanerId,
  }) async {
    try {
      // Check verification
      bool isVerified = await checkCleanerVerification(cleanerId);
      if (!isVerified) {
        Get.snackbar(
          'Verification Required',
          'Your account must be verified by admin before updating services',
        );
        return false;
      }

      // Validate service
      String? validationError = _validateService(service);
      if (validationError != null) {
        Get.snackbar('Validation Error', validationError);
        return false;
      }

      isCreatingService.value = true;

      // Upload new images if any
      if (selectedImageFiles.isNotEmpty) {
        List<String> imageUrls = await uploadImages(
          cleanerId: cleanerId,
          serviceId: service.serviceId,
        );
        // Merge with existing images
        service.images = [...(service.images ?? []), ...imageUrls];
      }

      // Update service in Firestore
      await ServiceDbServices.updateService(service);

      isCreatingService.value = false;

      // Reset form
      selectedImageFiles.clear();
      uploadedImageUrls.clear();
      currentService = null;

      // Get.snackbar('Success', 'Service updated successfully');
      // Reload appropriate services based on user type
      if (isCleanerMode && currentUserId != null) {
        await loadMyServices(currentUserId!);
      } else {
        await loadAllServices();
      }
      return true;
    } catch (e) {
      isCreatingService.value = false;
      Get.snackbar('Error', 'Failed to update service: ${e.toString()}');
      return false;
    }
  }

  /// Delete a service
  Future<bool> deleteService({
    required String serviceId,
    required String cleanerId,
  }) async {
    try {
      // Delete images from storage
      ServiceModel? service = await ServiceDbServices.getServiceById(serviceId);
      if (service != null &&
          service.images != null &&
          service.images!.isNotEmpty) {
        await StorageServices.deleteMultipleServiceImages(service.images!);
      }

      // Delete service
      await ServiceDbServices.deleteService(serviceId);

      Get.snackbar('Success', 'Service deleted successfully');
      // Reload appropriate services based on user type
      if (isCleanerMode && currentUserId != null) {
        await loadMyServices(currentUserId!);
      } else {
        await loadAllServices();
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete service: ${e.toString()}');
      return false;
    }
  }

  /// Toggle service active status
  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      await ServiceDbServices.toggleServiceStatus(serviceId, isActive);
      // Reload appropriate services based on user type
      if (isCleanerMode && currentUserId != null) {
        await loadMyServices(currentUserId!);
      } else {
        await loadAllServices();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update service status: ${e.toString()}');
    }
  }

  /// Validate service based on category and type
  String? _validateService(ServiceModel service) {
    if (service.serviceCategory == ServiceCategory.cleaning) {
      return ServiceValidators.validateCleaningService(
        title: service.title,
        description: service.description,
        pricingOptions: service.pricingOptions
            ?.map((opt) => opt.toMap())
            .toList(),
        location: service.location,
        images: service.images,
      );
    } else if (service.serviceCategory == ServiceCategory.landscaping) {
      return ServiceValidators.validateLandscapingService(
        title: service.title,
        description: service.description,
        pricingOptions: service.pricingOptions
            ?.map((opt) => opt.toMap())
            .toList(),
        basePrice: service.basePrice,
        location: service.location,
        images: service.images,
      );
    }
    return 'Invalid service category or type';
  }

  /// Get minimum price for a service
  double? getMinPrice(ServiceModel service) {
    return service.getMinPrice();
  }

  /// Check if service is quote-based
  bool isQuoteBased(ServiceModel service) {
    return service.isQuoteBased();
  }
}
