import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeConnectService {
  static final CollectionReference _usersRef = FirebaseFirestore.instance
      .collection('users');
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Create Stripe Connect account for a provider
  /// Returns onboarding URL
  static Future<String> createConnectAccount(String userId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _functions
          .httpsCallable('createStripeConnectAccount')
          .call({'userId': userId});

      if (response.data['accountId'] == null ||
          response.data['onboardingUrl'] == null) {
        throw Exception(
          'Failed to create Stripe Connect account: ${response.data}',
        );
      }

      final accountId = response.data['accountId'] as String;
      final onboardingUrl = response.data['onboardingUrl'] as String;

      // Store account ID in user document
      await _usersRef.doc(userId).update({
        'stripeConnectAccountId': accountId,
        'stripeConnectOnboardingComplete': false,
      });

      return onboardingUrl;
    } catch (e) {
      throw Exception('Failed to create Stripe Connect account: $e');
    }
  }

  /// Get Stripe Connect account status
  static Future<Map<String, dynamic>> getAccountStatus(String userId) async {
    try {
      final userDoc = await _usersRef.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final accountId = data['stripeConnectAccountId'] as String?;
      final onboardingComplete =
          data['stripeConnectOnboardingComplete'] as bool? ?? false;

      if (accountId == null) {
        return {'hasAccount': false, 'onboardingComplete': false};
      }

      // Check account status with Stripe
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _functions
          .httpsCallable('getStripeConnectAccountStatus')
          .call({'accountId': accountId});

      return {
        'hasAccount': true,
        'accountId': accountId,
        // 'onboardingComplete':
        //     onboardingComplete &&
        //     (response.data['chargesEnabled'] as bool? ?? false),
        'onboardingComplete':
            response.data['detailsSubmitted'] as bool? ?? false,

        'chargesEnabled': response.data['chargesEnabled'] as bool? ?? false,
        'payoutsEnabled': response.data['payoutsEnabled'] as bool? ?? false,
      };
    } catch (e) {
      throw Exception('Failed to get account status: $e');
    }
  }

  /// Check if provider has completed Stripe Connect onboarding
  static Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final status = await getAccountStatus(userId);
      return status['onboardingComplete'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}
