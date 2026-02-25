import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/service_model.dart';

class ServiceDbServices {
  static CollectionReference servicesRef = FirebaseFirestore.instance
      .collection('services');

  // -------------------- Service CRUD Operations -------------------

  /// Add a new service to Firestore
  static Future<String> addService(ServiceModel service) async {
    try {
      DocumentReference docRef = await servicesRef.add(service.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  /// Update an existing service
  static Future<void> updateService(ServiceModel service) async {
    try {
      if (service.serviceId == null) {
        throw Exception('Service ID is required for update');
      }
      await servicesRef.doc(service.serviceId).update(service.toMap());
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  /// Delete a service
  static Future<void> deleteService(String serviceId) async {
    try {
      await servicesRef.doc(serviceId).delete();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  /// Get a single service by ID
  static Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      DocumentSnapshot doc = await servicesRef.doc(serviceId).get();
      if (doc.exists) {
        return ServiceModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  /// Get all services by cleaner ID
  static Future<List<ServiceModel>> getServicesByCleaner(
    String cleanerId,
  ) async {
    try {
      QuerySnapshot querySnapshot = await servicesRef
          .where('cleanerId', isEqualTo: cleanerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get services by cleaner: $e');
    }
  }

  /// Get all active services (for customers)
  static Future<List<ServiceModel>> getAllActiveServices() async {
    try {
      QuerySnapshot querySnapshot = await servicesRef
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active services: $e');
    }
  }

  /// Get services by category
  static Future<List<ServiceModel>> getServicesByCategory(
    ServiceCategory category,
  ) async {
    try {
      QuerySnapshot querySnapshot = await servicesRef
          .where('category', isEqualTo: category.toJson())
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get services by category: $e');
    }
  }


  /// Get services by location (partial match)
  static Future<List<ServiceModel>> getServicesByLocation(
    String location,
  ) async {
    try {
      QuerySnapshot querySnapshot = await servicesRef
          .where('isActive', isEqualTo: true)
          .orderBy('location')
          .get();

      // Filter by location (case-insensitive partial match)
      String searchLocation = location.toLowerCase();
      List<ServiceModel> allServices = querySnapshot.docs
          .map((doc) => ServiceModel.fromDocument(doc))
          .toList();

      return allServices
          .where(
            (service) =>
                service.location?.toLowerCase().contains(searchLocation) ??
                false,
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get services by location: $e');
    }
  }

  /// Stream all active services (real-time updates)
  static Stream<List<ServiceModel>> streamActiveServices() {
    return servicesRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Stream services by cleaner (real-time updates)
  static Stream<List<ServiceModel>> streamServicesByCleaner(String cleanerId) {
    return servicesRef
        .where('cleanerId', isEqualTo: cleanerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Toggle service active status
  static Future<void> toggleServiceStatus(
    String serviceId,
    bool isActive,
  ) async {
    try {
      await servicesRef.doc(serviceId).update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle service status: $e');
    }
  }
}
