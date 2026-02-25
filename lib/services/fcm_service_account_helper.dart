import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Helper class to manage FCM HTTP v1 API authentication using Service Account
class FcmServiceAccountHelper {
  FcmServiceAccountHelper._();

  static AutoRefreshingAuthClient? _authClient;
  static String? _projectId;
  static bool _isInitialized = false;
  static bool _initializationFailed = false;

  /// Check if dotenv is loaded
  static bool get _isDotEnvLoaded {
    try {
      // Try to access dotenv - if it throws, it's not loaded
      dotenv.env;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize the service account from environment variables
  /// Expects FIREBASE_PROJECT_ID and FIREBASE_SERVICE_ACCOUNT_JSON in .env
  static Future<void> initialize() async {
    if (_isInitialized) return;
    if (_initializationFailed) return;

    if (!_isDotEnvLoaded) {
      _initializationFailed = true;
      throw Exception('DotEnv is not loaded. Make sure .env file is loaded before initializing FCM.');
    }

    _projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    final serviceAccountJson = dotenv.env['FIREBASE_SERVICE_ACCOUNT_JSON'];

    if (_projectId == null || _projectId!.isEmpty) {
      throw Exception(
        'FIREBASE_PROJECT_ID is missing in .env file',
      );
    }

    if (serviceAccountJson == null || serviceAccountJson.isEmpty) {
      throw Exception(
        'FIREBASE_SERVICE_ACCOUNT_JSON is missing in .env file',
      );
    }

    try {
      // Parse the service account JSON
      final serviceAccount = jsonDecode(serviceAccountJson) as Map<String, dynamic>;

      // Create credentials from service account
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      // Create an authenticated HTTP client
      _authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );
      _isInitialized = true;
    } catch (e) {
      _initializationFailed = true;
      throw Exception('Failed to initialize service account: $e');
    }
  }

  /// Get the access token for FCM API
  static Future<String> getAccessToken() async {
    // If initialization failed before, don't try again
    if (_initializationFailed) {
      throw Exception('FCM Service Account initialization failed. Check your .env file.');
    }

    // If not initialized, try to initialize
    if (_authClient == null && !_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        _initializationFailed = true;
        throw Exception('Failed to initialize FCM Service Account: $e');
      }
    }

    if (_authClient == null) {
      throw Exception('Failed to initialize auth client');
    }

    // The auth client automatically refreshes tokens
    final credentials = _authClient!.credentials;
    return credentials.accessToken.data;
  }

  /// Get the Firebase project ID
  static String get projectId {
    if (_projectId == null || _projectId!.isEmpty) {
      throw Exception('FIREBASE_PROJECT_ID is not set');
    }
    return _projectId!;
  }

  /// Dispose the auth client
  static void dispose() {
    _authClient?.close();
    _authClient = null;
  }
}

