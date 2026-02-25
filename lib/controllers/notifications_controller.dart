import 'package:get/get.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:home_cleaning_app/services/notification_db_service.dart';

class NotificationsController extends GetxController {
  // Notifications list
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Loading state
  RxBool isLoading = true.obs;

  // Unread count
  RxInt unreadCount = 0.obs;

  // // Current user ID
  // String? get currentUserId {
  //   try {
  //     final authController = Get.find();
  //     // You'll need to import AuthController and get userId from there
  //     // For now, we'll get it from the parameter
  //     return _userId;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  String? _userId;

  @override
  void onInit() {
    super.onInit();
  }

  /// Initialize with user ID
  void initialize(String userId) {
    _userId = userId;
    loadNotifications();
    streamNotifications();
    streamUnreadCount();
  }

  /// Load notifications for the current user
  Future<void> loadNotifications() async {
    if (_userId == null) return;

    try {
      isLoading.value = true;
      notifications.value = await NotificationDbService.getUserNotifications(
        _userId!,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Stream notifications for real-time updates
  void streamNotifications() {
    if (_userId == null) return;

    NotificationDbService.streamUserNotifications(_userId!).listen((
      notificationsList,
    ) {
      notifications.value = notificationsList;
    });
  }

  /// Stream unread count for real-time updates
  void streamUnreadCount() {
    if (_userId == null) return;

    NotificationDbService.streamUnreadCount(_userId!).listen((count) {
      unreadCount.value = count;
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationDbService.markAsRead(notificationId);
      // Update local state
      final index = notifications.indexWhere(
        (n) => n.notificationId == notificationId,
      );
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read: ${e.toString()}',
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      await NotificationDbService.markAllAsRead(_userId!);
      // Update local state
      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all as read: ${e.toString()}');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationDbService.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.notificationId == notificationId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notification: ${e.toString()}');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_userId == null) return;

    try {
      await NotificationDbService.deleteAllUserNotifications(_userId!);
      notifications.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete all notifications: ${e.toString()}',
      );
    }
  }

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return notifications.where((n) => n.isRead == false).toList();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }
}
