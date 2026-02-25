import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/notification_model.dart';

class NotificationDbService {
  static CollectionReference get _notificationsRef =>
      FirebaseFirestore.instance.collection('notifications');

  /// Save a notification to Firestore
  static Future<String> saveNotification(NotificationModel notification) async {
    try {
      final docRef = await _notificationsRef.add(notification.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  /// Get all notifications for a user, ordered by creation date (newest first)
  static Future<List<NotificationModel>> getUserNotifications(
    String userId,
  ) async {
    try {
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  /// Stream notifications for a user (real-time updates)
  static Stream<List<NotificationModel>> streamUserNotifications(
    String userId,
  ) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Mark a notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  static Future<void> markAllAsRead(String userId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Get unread notification count for a user
  static Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Stream unread notification count (real-time updates)
  static Stream<int> streamUnreadCount(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for a user
  static Future<void> deleteAllUserNotifications(String userId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }
}

