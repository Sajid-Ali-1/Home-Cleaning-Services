import 'dart:math';

/// Calculate distance between two coordinates using Haversine formula
/// Returns distance in kilometers
double calculateDistanceInKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadiusKm = 6371.0;

  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double distanceKm = earthRadiusKm * c;

  return distanceKm;
}

/// Calculate distance between two coordinates using Haversine formula
/// Returns distance in miles
double calculateDistanceInMiles(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadiusMiles = 3959.0;

  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double distanceMiles = earthRadiusMiles * c;

  return distanceMiles;
}

/// Convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}

/// Check if customer location is within service radius
/// 
/// Returns true if customer is within the service radius, false otherwise
/// 
/// Parameters:
/// - customerLat: Customer's latitude
/// - customerLon: Customer's longitude
/// - serviceLat: Service provider's latitude
/// - serviceLon: Service provider's longitude
/// - radius: Service radius value
/// - radiusUnit: Unit of radius ('km' or 'miles')
bool isCustomerWithinServiceRadius({
  required double customerLat,
  required double customerLon,
  required double serviceLat,
  required double serviceLon,
  required double radius,
  required String radiusUnit,
}) {
  double distance;
  
  if (radiusUnit.toLowerCase() == 'miles') {
    distance = calculateDistanceInMiles(
      customerLat,
      customerLon,
      serviceLat,
      serviceLon,
    );
  } else {
    // Default to km
    distance = calculateDistanceInKm(
      customerLat,
      customerLon,
      serviceLat,
      serviceLon,
    );
  }

  return distance <= radius;
}

/// Get distance between customer and service in the specified unit
/// 
/// Returns distance in the same unit as radiusUnit
double getDistanceToService({
  required double customerLat,
  required double customerLon,
  required double serviceLat,
  required double serviceLon,
  required String radiusUnit,
}) {
  if (radiusUnit.toLowerCase() == 'miles') {
    return calculateDistanceInMiles(
      customerLat,
      customerLon,
      serviceLat,
      serviceLon,
    );
  } else {
    // Default to km
    return calculateDistanceInKm(
      customerLat,
      customerLon,
      serviceLat,
      serviceLon,
    );
  }
}

