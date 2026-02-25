import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerLocationController extends GetxController {
  // Location data
  RxnDouble latitude = RxnDouble();
  RxnDouble longitude = RxnDouble();
  RxString address = ''.obs;
  
  // Loading states
  RxBool isGettingLocation = false.obs;
  RxBool hasLocation = false.obs;
  
  // SharedPreferences keys
  static const String _latitudeKey = 'customer_latitude';
  static const String _longitudeKey = 'customer_longitude';
  static const String _addressKey = 'customer_address';

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocation();
  }

  /// Load saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble(_latitudeKey);
      final savedLng = prefs.getDouble(_longitudeKey);
      final savedAddress = prefs.getString(_addressKey);

      if (savedLat != null && savedLng != null) {
        latitude.value = savedLat;
        longitude.value = savedLng;
        address.value = savedAddress ?? '';
        hasLocation.value = true;
      } else {
        // If no saved location, get current location
        await getCurrentLocation();
      }
    } catch (e) {
      // If loading fails, try to get current location
      await getCurrentLocation();
    }
  }

  /// Save location to SharedPreferences
  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (latitude.value != null && longitude.value != null) {
        await prefs.setDouble(_latitudeKey, latitude.value!);
        await prefs.setDouble(_longitudeKey, longitude.value!);
        await prefs.setString(_addressKey, address.value);
      }
    } catch (e) {
      // Silently fail - location will still work, just won't persist
      debugPrint('Failed to save location: $e');
    }
  }

  /// Get current location using GPS
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
            'Location permissions are required to find services near you.',
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
          final formattedAddress = _formatAddress(place);
          setLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            address: formattedAddress,
          );
        } else {
          setLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            address: '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          );
        }
      } catch (e) {
        // If geocoding fails, still set coordinates
        setLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        );
      }

      isGettingLocation.value = false;
    } catch (e) {
      isGettingLocation.value = false;
      Get.snackbar('Error', 'Failed to get location: ${e.toString()}');
    }
  }

  /// Set location from map picker
  Future<void> setLocationFromMap({
    required double latitude,
    required double longitude,
  }) async {
    try {
      isGettingLocation.value = true;
      String formattedAddress;
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        formattedAddress = placemarks.isNotEmpty
            ? _formatAddress(placemarks.first)
            : '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      } catch (e) {
        formattedAddress =
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      }
      setLocation(
        latitude: latitude,
        longitude: longitude,
        address: formattedAddress,
      );
    } finally {
      isGettingLocation.value = false;
    }
  }

  /// Set location coordinates and address
  void setLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    this.latitude.value = latitude;
    this.longitude.value = longitude;
    this.address.value = address;
    hasLocation.value = true;
    _saveLocation();
  }

  /// Format address from placemark
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

  /// Clear location
  void clearLocation() {
    latitude.value = null;
    longitude.value = null;
    address.value = '';
    hasLocation.value = false;
    _clearSavedLocation();
  }

  /// Clear saved location from SharedPreferences
  Future<void> _clearSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_latitudeKey);
      await prefs.remove(_longitudeKey);
      await prefs.remove(_addressKey);
    } catch (e) {
      debugPrint('Failed to clear saved location: $e');
    }
  }
}

