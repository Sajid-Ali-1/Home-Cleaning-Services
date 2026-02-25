import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/bookings_controller.dart';
import 'package:home_cleaning_app/controllers/nav_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:home_cleaning_app/services/booking_db_service.dart';
import 'package:home_cleaning_app/services/fcm_service_account_helper.dart';
import 'package:home_cleaning_app/services/notification_db_service.dart';
import 'package:home_cleaning_app/views/screens/chat/chat_screen.dart';
import 'package:home_cleaning_app/views/screens/nav_pages/nav_page.dart';

/// Result of sending notification to a token
class _SendResult {
  final bool success;
  final String? errorCode;
  final String token;

  _SendResult({required this.success, this.errorCode, required this.token});
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'booking_updates',
    'Booking Updates',
    description: 'Notifications about booking requests and status changes',
    importance: Importance.max,
  );

  static bool _isInitialized = false;
  static bool _isInitializing = false;

  static Future<void> initialize() async {
    // Prevent multiple simultaneous initialization calls
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    try {
      // Configure local notifications first (required for Android)
      await _configureLocalNotifications();

      // Request notification permissions
      final settings = await _messaging.getNotificationSettings();
      print(
        '🔔 Current notification authorization status: ${settings.authorizationStatus}',
      );

      // Request permission if not already authorized
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        print('🔔 Requesting notification permissions...');
        final requestResult = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false, // Request full permission, not provisional
        );
        print(
          '🔔 Permission request result: ${requestResult.authorizationStatus}',
        );
        print('   Alert: ${requestResult.alert}');
        print('   Badge: ${requestResult.badge}');
        print('   Sound: ${requestResult.sound}');
      } else {
        print('🔔 Notification permissions already granted');
      }

      // Set up message handlers
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app opens from terminated/background state
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

      // Check if app was opened from a notification (terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('📱 App opened from notification (terminated state)');
        // Delay to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 1000), () {
          _handleNotificationOpenedApp(initialMessage);
        });
      }

      _isInitialized = true;
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
    } finally {
      _isInitializing = false;
    }
  }

  static Future<void> _configureLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    const settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Handle notification tap on iOS (legacy)
  @pragma('vm:entry-point')
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    print('📱 Received local notification (iOS legacy): $title');
    if (payload != null) {
      _handleNotificationNavigation(payload);
    }
  }

  /// Handle notification tap
  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // Try to parse payload as JSON (new format with type)
        final payloadData =
            jsonDecode(response.payload!) as Map<String, dynamic>?;
        if (payloadData != null) {
          final bookingId = payloadData['bookingId'] as String? ?? '';
          final typeString = payloadData['type'] as String?;
          final notificationType = typeString != null
              ? NotificationType.fromJson(typeString)
              : null;

          if (bookingId.isNotEmpty) {
            _handleNotificationNavigation(
              bookingId,
              notificationType: notificationType,
            );
            return;
          }
        }
      } catch (e) {
        // If JSON parsing fails, treat as old format (just bookingId string)
        print('⚠️ Failed to parse payload as JSON, using as bookingId: $e');
      }

      // Fallback: treat payload as bookingId (old format)
      _handleNotificationNavigation(response.payload!, notificationType: null);
    } else {
      _navigateToBookingsScreen();
    }
  }

  /// Handle navigation based on notification data
  static Future<void> _handleNotificationNavigation(
    String payload, {
    NotificationType? notificationType,
    Map<String, dynamic>? notificationData,
  }) async {
    try {
      // Parse payload - it should be bookingId for booking notifications
      // or chatId for message notifications (which is also a bookingId)
      final bookingId = payload;

      if (bookingId.isEmpty) {
        print('⚠️ Empty notification payload');
        _navigateToBookingsScreen();
        return;
      }

      // Wait a bit for app to be ready if coming from terminated state
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is authenticated
      if (!Get.isRegistered<AuthController>()) {
        print('⚠️ AuthController not registered, cannot navigate');
        _navigateToBookingsScreen();
        return;
      }

      final authController = Get.find<AuthController>();
      if (authController.userModel == null) {
        print('⚠️ User not authenticated, cannot navigate');
        _navigateToBookingsScreen();
        return;
      }

      // Check if this is a message notification - navigate to chat screen
      if (notificationType == NotificationType.message) {
        try {
          final booking = await BookingDbService.getBookingById(bookingId);
          if (booking != null) {
            // Determine if user is provider or customer
            final userId = authController.userModel!.uid;
            final isProviderView = booking.providerId == userId;

            // Navigate to chat screen
            Get.to(
              () =>
                  ChatScreen(booking: booking, isProviderView: isProviderView),
            );
            return;
          }
        } catch (e) {
          print('⚠️ Error fetching booking for chat: $e');
          // Fall through to bookings screen navigation
        }
      }

      // For non-message notifications, navigate to bookings screen
      BookingModel? booking;
      BookingListFilter? targetTab;

      try {
        booking = await BookingDbService.getBookingById(bookingId);
        if (booking != null) {
          // Determine the correct tab based on notification type and booking status
          targetTab = _determineBookingTab(notificationType, booking);
        }
      } catch (e) {
        print('⚠️ Error fetching booking: $e');
      }

      // Navigate to bookings screen with appropriate tab
      _navigateToBookingsScreen(targetTab: targetTab);
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
      // Fallback: navigate to bookings screen
      _navigateToBookingsScreen();
    }
  }

  /// Determine which bookings tab to show based on notification type and booking status
  static BookingListFilter _determineBookingTab(
    NotificationType? type,
    BookingModel booking,
  ) {
    final now = DateTime.now();
    final startTime = booking.startTime.toDate();

    // Determine tab based on notification type
    switch (type) {
      case NotificationType.bookingRequest:
        return BookingListFilter.requests;

      case NotificationType.bookingAccepted:
        // If accepted and in the future, show upcoming; otherwise past
        if (startTime.isAfter(now)) {
          return BookingListFilter.upcoming;
        } else {
          return BookingListFilter.past;
        }

      case NotificationType.bookingRejected:
      case NotificationType.bookingCanceled:
      case NotificationType.bookingCompleted:
      case NotificationType.payoutProcessed:
      case NotificationType.payoutFailed:
        return BookingListFilter.past;

      case NotificationType.message:
        // For messages, determine based on booking status
        if (booking.status == BookingStatus.requested) {
          return BookingListFilter.requests;
        } else if (booking.status == BookingStatus.accepted &&
            startTime.isAfter(now)) {
          return BookingListFilter.upcoming;
        } else {
          return BookingListFilter.past;
        }

      case NotificationType.system:
      case NotificationType.other:
      case null:
        // Default: determine based on booking status
        if (booking.status == BookingStatus.requested) {
          return BookingListFilter.requests;
        } else if (booking.status == BookingStatus.accepted &&
            startTime.isAfter(now)) {
          return BookingListFilter.upcoming;
        } else {
          return BookingListFilter.past;
        }
    }
  }

  /// Navigate to bookings screen with optional tab filter
  static void _navigateToBookingsScreen({BookingListFilter? targetTab}) {
    try {
      // Ensure we're on the nav page first
      if (Get.currentRoute != '/nav') {
        Get.offAll(() => const NavPage(), routeName: '/nav');
        // Wait for navigation to complete, then switch to bookings tab and filter
        Future.delayed(const Duration(milliseconds: 500), () {
          _switchToBookingsTab(targetTab: targetTab);
        });
      } else {
        // Already on nav page, just switch to bookings tab and filter
        _switchToBookingsTab(targetTab: targetTab);
      }
    } catch (e) {
      print('❌ Error navigating to bookings screen: $e');
    }
  }

  /// Switch to bookings tab and set the filter
  static void _switchToBookingsTab({BookingListFilter? targetTab}) {
    try {
      // Switch to bookings tab (index 1)
      if (Get.isRegistered<NavController>()) {
        final navController = Get.find<NavController>();
        navController.changeTabIndex(1);
      }

      // Set the filter if targetTab is specified and BookingsController is available
      if (targetTab != null) {
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            if (Get.isRegistered<BookingsController>()) {
              final bookingsController = Get.find<BookingsController>();
              bookingsController.changeFilter(targetTab);
              print('✅ Switched to bookings tab with filter: $targetTab');
            }
          } catch (e) {
            print('⚠️ Could not set bookings filter: $e');
          }
        });
      }
    } catch (e) {
      print('⚠️ Could not switch to bookings tab: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Note: Notification is already saved to Firestore by sendNotificationToUser
    // No need to save again here to avoid duplicates

    // Extract bookingId or chatId from data for payload
    final bookingId = message.data['bookingId'] ?? message.data['chatId'] ?? '';
    final typeString = message.data['type'] as String?;

    // Encode payload as JSON to include both bookingId and type
    final payload = bookingId.isNotEmpty
        ? jsonEncode({'bookingId': bookingId, 'type': typeString ?? 'other'})
        : '';

    // Show local notification (only needed in foreground since FCM doesn't auto-show)
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Handle notification tap when app opens from background/terminated state
  static Future<void> _handleNotificationOpenedApp(
    RemoteMessage message,
  ) async {
    print('📱 Notification opened app: ${message.data}');

    // Extract bookingId or chatId from notification data
    final bookingId = message.data['bookingId'] as String?;
    final chatId = message.data['chatId'] as String?;
    final typeString = message.data['type'] as String?;

    // Parse notification type
    NotificationType? notificationType;
    if (typeString != null) {
      notificationType = NotificationType.fromJson(typeString);
    }

    if (bookingId != null && bookingId.isNotEmpty) {
      await _handleNotificationNavigation(
        bookingId,
        notificationType: notificationType,
        notificationData: message.data,
      );
    } else if (chatId != null && chatId.isNotEmpty) {
      // For chat notifications, chatId is typically the bookingId
      await _handleNotificationNavigation(
        chatId,
        notificationType: notificationType ?? NotificationType.message,
        notificationData: message.data,
      );
    } else {
      print('⚠️ No bookingId or chatId in notification data');
      _navigateToBookingsScreen();
    }
  }

  static Future<void> registerDeviceToken(String userId) async {
    try {
      // On iOS, wait for APNS token to be available
      if (Platform.isIOS) {
        // Wait a bit for APNS token to be set
        await Future.delayed(Duration(milliseconds: 500));
      }

      final token = await _messaging.getToken();
      if (token == null) {
        print('FCM token is null, skipping registration');
        return;
      }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      await userRef.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error registering device token: $e');
      // Don't throw - fail silently to avoid blocking user flow
    }
  }

  /// Remove the current device's FCM token from the user's tokens list
  /// Should be called when user signs out
  static Future<void> unregisterDeviceToken(String userId) async {
    try {
      // On iOS, wait for APNS token to be available
      if (Platform.isIOS) {
        // Wait a bit for APNS token to be set
        await Future.delayed(Duration(milliseconds: 500));
      }

      final token = await _messaging.getToken();
      if (token == null) {
        print('FCM token is null, skipping unregistration');
        return;
      }
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      await userRef.set({
        'fcmTokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error unregistering device token: $e');
      // Don't throw - fail silently to avoid blocking sign out
    }
  }

  /// Send notification to a user using FCM HTTP v1 API
  /// Also saves the notification to Firestore
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    NotificationType? type,
    Map<String, String>? data,
  }) async {
    try {
      // Get access token from service account
      String? accessToken;
      String? projectId;

      try {
        accessToken = await FcmServiceAccountHelper.getAccessToken();
        projectId = FcmServiceAccountHelper.projectId;
      } catch (e) {
        print('Warning: Failed to get FCM access token: $e');
        print(
          'Notification will be saved to Firestore but push notification will not be sent.',
        );
        // Continue to save notification to Firestore even if push fails
        accessToken = null;
        projectId = null;
      }

      // If we don't have access token, skip push notification but still save to Firestore
      if (accessToken == null || projectId == null) {
        // Save notification to Firestore only
        await _saveNotificationToFirestore(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
        );
        return;
      }

      // Get user's FCM tokens
      final tokens = await _fetchUserTokens(userId);
      if (tokens.isEmpty) {
        // Save notification to Firestore even if no tokens
        await _saveNotificationToFirestore(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
        );
        return; // User has no registered tokens
      }

      // Send notification to each token (FCM v1 requires one request per token)
      // At this point, accessToken and projectId are guaranteed to be non-null
      final results = await Future.wait(
        tokens.map(
          (token) => _sendToToken(
            accessToken: accessToken!,
            projectId: projectId!,
            token: token,
            title: title,
            body: body,
            data: data,
          ),
        ),
      );

      // Collect invalid tokens that need to be removed
      final invalidTokens = <String>[];
      for (final result in results) {
        if (!result.success) {
          // Check for UNREGISTERED or other invalid token errors
          if (result.errorCode == 'UNREGISTERED' ||
              result.errorCode == 'INVALID_ARGUMENT') {
            invalidTokens.add(result.token);
            print(
              'Token is invalid (${result.errorCode}): ${result.token.substring(0, 20)}...',
            );
          }
        }
      }

      // Remove invalid tokens from Firestore
      if (invalidTokens.isNotEmpty) {
        await _removeInvalidTokens(userId, invalidTokens);
      }

      // Log any failures (optional - you can handle errors as needed)
      final failures = results.where((r) => !r.success).length;
      if (failures > 0) {
        print(
          'Failed to send ${failures} out of ${tokens.length} notifications',
        );
      }

      // Save notification to Firestore (even if push failed)
      await _saveNotificationToFirestore(
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
      );
    } catch (e) {
      print('Error sending notification: $e');
      // Try to save to Firestore even if everything else failed
      try {
        await _saveNotificationToFirestore(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
        );
      } catch (saveError) {
        print('Error saving notification to Firestore: $saveError');
      }
      // Don't throw - fail silently to avoid breaking the app
    }
  }

  /// Helper method to save notification to Firestore
  static Future<void> _saveNotificationToFirestore({
    required String userId,
    required String title,
    required String body,
    NotificationType? type,
    Map<String, String>? data,
  }) async {
    try {
      // Determine notification type from data if not provided
      NotificationType? finalType = type;
      if (finalType == null && data != null) {
        final typeString = data['type'];
        if (typeString != null) {
          finalType = NotificationType.fromJson(typeString);
        } else if (data['bookingId'] != null) {
          // Infer from context
          final status = data['status'];
          if (status == 'requested') {
            finalType = NotificationType.bookingRequest;
          } else if (status == 'accepted') {
            finalType = NotificationType.bookingAccepted;
          } else if (status == 'rejected') {
            finalType = NotificationType.bookingRejected;
          } else if (status == 'canceled') {
            finalType = NotificationType.bookingCanceled;
          } else if (status == 'completed') {
            finalType = NotificationType.bookingCompleted;
          }
        } else if (data['chatId'] != null) {
          finalType = NotificationType.message;
        }
      }

      // Ensure userId is in data for incoming notifications
      final notificationData = Map<String, dynamic>.from(data ?? {});
      notificationData['userId'] = userId;

      final notificationModel = NotificationModel(
        userId: userId,
        title: title,
        body: body,
        type: finalType ?? NotificationType.other,
        isRead: false,
        data: notificationData,
      );
      await NotificationDbService.saveNotification(notificationModel);
    } catch (e) {
      print('Error saving notification to Firestore: $e');
      // Don't throw - fail silently
    }
  }

  /// Send notification to a single FCM token using HTTP v1 API
  static Future<_SendResult> _sendToToken({
    required String accessToken,
    required String projectId,
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Build FCM v1 API payload
      final payload = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': data?.map((key, value) => MapEntry(key, value)) ?? {},
          'android': {'priority': 'high'},
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': body},
                'sound': 'default',
              },
            },
          },
        },
      };

      // FCM HTTP v1 API endpoint
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return _SendResult(success: true, token: token);
      } else {
        // Parse error response to extract error code
        String? errorCode;
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errorBody['error'];
          if (error != null && error is Map<String, dynamic>) {
            final details = error['details'] as List<dynamic>?;
            if (details != null && details.isNotEmpty) {
              final firstDetail = details.first as Map<String, dynamic>?;
              if (firstDetail != null) {
                errorCode = firstDetail['errorCode'] as String?;
              }
            }
          }
        } catch (e) {
          // Failed to parse error, continue with null errorCode
        }

        print('FCM v1 API error: ${response.statusCode} - ${response.body}');
        return _SendResult(success: false, errorCode: errorCode, token: token);
      }
    } catch (e) {
      print('Error sending to token: $e');
      return _SendResult(success: false, token: token);
    }
  }

  static Future<List<String>> _fetchUserTokens(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final data = doc.data();
    if (data == null || data['fcmTokens'] == null) return [];
    return List<String>.from(data['fcmTokens'] as List<dynamic>);
  }

  /// Remove invalid FCM tokens from a user's token list
  static Future<void> _removeInvalidTokens(
    String userId,
    List<String> invalidTokens,
  ) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      // Remove all invalid tokens at once
      await userRef.update({
        'fcmTokens': FieldValue.arrayRemove(invalidTokens),
      });

      print(
        'Removed ${invalidTokens.length} invalid token(s) for user $userId',
      );
    } catch (e) {
      print('Error removing invalid tokens: $e');
      // Don't throw - fail silently
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Note:
  // 1. Notification is already saved to Firestore by sendNotificationToUser
  //    No need to save again here to avoid duplicates
  // 2. FCM automatically shows a notification in background/terminated state
  //    when the payload contains a "notification" field, so we don't need to
  //    manually show a local notification here. This prevents duplicate
  //    notifications on the device.

  // The notification will be automatically displayed by FCM/OS
  // and tap handling is done via onMessageOpenedApp / getInitialMessage
}
