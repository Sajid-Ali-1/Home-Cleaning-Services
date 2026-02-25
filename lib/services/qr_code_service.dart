import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:home_cleaning_app/data/platform_config.dart';

class QrCodeService {
  /// Generate completion QR code for a booking
  /// Returns QR code data as JSON string
  static Future<String> generateCompletionQrCode({
    required String bookingId,
    required DateTime startTime,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final projectId = FirebaseAuth.instance.app.options.projectId;
      final url = 'https://$projectId.cloudfunctions.net/generateCompletionQrCode';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'bookingId': bookingId,
            'startTime': Timestamp.fromDate(startTime).millisecondsSinceEpoch,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate QR code: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>;
      return jsonEncode({
        'bookingId': bookingId,
        'verificationToken': result['verificationToken'] as String,
        'timestamp': result['timestamp'] as int,
      });
    } catch (e) {
      throw Exception('Failed to generate QR code: $e');
    }
  }

  /// Validate scanned QR code
  /// Returns true if valid, throws exception if invalid
  static Future<bool> validateQrCode({
    required String bookingId,
    required String verificationToken,
    required String providerId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final projectId = FirebaseAuth.instance.app.options.projectId;
      if (projectId.isEmpty) {
        throw Exception('Firebase project ID not configured');
      }
      final url = 'https://$projectId.cloudfunctions.net/validateCompletionQrCode';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'bookingId': bookingId,
            'verificationToken': verificationToken,
            'providerId': providerId,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('QR code validation failed: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>;
      return result['valid'] as bool? ?? false;
    } catch (e) {
      throw Exception('QR code validation failed: $e');
    }
  }

  /// Check if QR code can be generated for a booking
  /// Returns true if booking start time is reached (or within 15 minutes before)
  static bool canGenerateQrCode(DateTime startTime) {
    final now = DateTime.now();
    final fifteenMinutesBefore = startTime.subtract(const Duration(minutes: 15));
    return now.isAfter(fifteenMinutesBefore) || now.isAtSameMomentAs(fifteenMinutesBefore);
  }

  /// Check if QR code has expired
  static bool isQrCodeExpired(DateTime startTime) {
    final expirationDate = startTime.add(Duration(
      days: PlatformConfig.defaultQrCodeExpirationDays,
    ));
    return DateTime.now().isAfter(expirationDate);
  }
}
