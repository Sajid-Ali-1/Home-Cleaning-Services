import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/availability_model.dart';
import 'package:home_cleaning_app/models/unit_price_option.dart';

enum ServiceCategory {
  cleaning,
  landscaping;

  // Convert enum to string for Firestore
  String toJson() => name;

  // Convert string to enum from Firestore
  static ServiceCategory? fromJson(String? value) {
    if (value == null) return null;
    try {
      return ServiceCategory.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}

enum ServiceType {
  standard,
  custom;

  // Convert enum to string for Firestore
  String toJson() => name;

  // Convert string to enum from Firestore
  static ServiceType? fromJson(String? value) {
    if (value == null) return null;
    try {
      return ServiceType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}

class ServiceModel {
  String? serviceId;
  String? cleanerId;
  ServiceCategory? serviceCategory;
  ServiceType?
  serviceType; // nullable - only for Landscaping: Standard or Custom
  String? title;
  String? description;
  List<UnitPriceOption>? pricingOptions; // nullable - for dynamic pricing
  double?
  basePrice; // nullable - optional base price for Standard/Custom Landscaping
  List<String>? images; // Firebase Storage URLs
  String? location; // service area: "City1, City2 (5.0 km)" or areas with radius
  Map<String, dynamic>? serviceArea; // {areas: [String], radius: double, radiusUnit: String}
  AvailabilitySchedule? availabilitySchedule;
  bool? isActive;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  ServiceModel({
    this.serviceId,
    this.cleanerId,
    this.serviceCategory,
    this.serviceType,
    this.title,
    this.description,
    this.pricingOptions,
    this.basePrice,
    this.images,
    this.location,
    this.serviceArea,
    this.availabilitySchedule,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Receiving data from server
  factory ServiceModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      serviceId: doc.id,
      cleanerId: docData['cleanerId'] as String?,
      serviceCategory: ServiceCategory.fromJson(docData['category'] as String?),
      serviceType: ServiceType.fromJson(docData['serviceType'] as String?),
      title: docData['title'] as String?,
      description: docData['description'] as String?,
      pricingOptions: docData['pricingOptions'] != null
          ? UnitPriceOption.fromList(
              docData['pricingOptions'] as List<dynamic>?,
            )
          : null,
      basePrice: (docData['basePrice'] as num?)?.toDouble(),
      images: docData['images'] != null
          ? List<String>.from(docData['images'] as List)
          : null,
      location: docData['location'] as String?,
      serviceArea: docData['serviceArea'] != null
          ? Map<String, dynamic>.from(docData['serviceArea'] as Map)
          : null,
      availabilitySchedule: docData['availability'] != null
          ? AvailabilitySchedule.fromMap(
              Map<String, dynamic>.from(
                docData['availability'] as Map,
              ),
            )
          : null,
      isActive: docData['isActive'] as bool? ?? true,
      createdAt: docData['createdAt'] as Timestamp?,
      updatedAt: docData['updatedAt'] as Timestamp?,
    );
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'cleanerId': cleanerId,
      'category': serviceCategory?.toJson(),
      'serviceType': serviceType?.toJson(),
      'title': title,
      'description': description,
      'pricingOptions': pricingOptions != null
          ? UnitPriceOption.toList(pricingOptions!)
          : null,
      'basePrice': basePrice,
      'images': images,
      'location': location,
      'serviceArea': serviceArea,
      'availability': availabilitySchedule?.toMap(),
      'isActive': isActive ?? true,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Get minimum price for display
  double? getMinPrice() {
    if (pricingOptions != null && pricingOptions!.isNotEmpty) {
      double min = pricingOptions!.first.calculateTotal(
        pricingOptions!.first.minQuantity <= 0
            ? 1.0
            : pricingOptions!.first.minQuantity,
      );
      for (var option in pricingOptions!) {
        final optionMinQty =
            option.minQuantity <= 0 ? 1.0 : option.minQuantity;
        final optionTotal = option.calculateTotal(optionMinQty);
        if (optionTotal < min) {
          min = optionTotal;
        }
      }
      return min;
    }
    return basePrice;
  }

  // Check if service is quote-based (deprecated - always returns false now)
  bool isQuoteBased() {
    // ServiceType concept removed - all services can have fixed pricing
    return false;
  }

  // Check if service has fixed pricing
  bool hasFixedPricing() {
    if (serviceCategory == ServiceCategory.cleaning) {
      return pricingOptions != null && pricingOptions!.isNotEmpty;
    }
    if (serviceCategory == ServiceCategory.landscaping) {
      return (pricingOptions != null && pricingOptions!.isNotEmpty) ||
          (basePrice != null && basePrice! > 0);
    }
    return false;
  }
  UnitPriceOption? get primaryPricingOption {
    if (pricingOptions == null || pricingOptions!.isEmpty) return null;
    return pricingOptions!.first;
  }

  String? get primaryUnitLabel => primaryPricingOption?.unitName;
}
