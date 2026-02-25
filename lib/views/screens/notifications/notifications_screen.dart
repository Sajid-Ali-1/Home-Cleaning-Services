import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/notifications_controller.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userId = authController.userModel?.uid;
    final theme = AppTheme.of(context);

    if (userId == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Center(
            child: Text(
              'Please log in to view notifications',
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
          ),
        ),
      );
    }

    final controller = Get.put(NotificationsController());
    controller.initialize(userId);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          // Header (similar to ServiceDetailsHeader)
          _NotificationsHeader(
            unreadCount: controller.unreadCount,
            onMarkAllRead: () => controller.markAllAsRead(),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Obx(() {
                      final unread = controller.unreadCount.value;
                      return Text(
                        unread > 0
                            ? 'You have $unread unread notification${unread > 1 ? 's' : ''}'
                            : 'Stay updated with your bookings and messages.',
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  // Notifications list
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.notifications.isEmpty) {
                        return const _EmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.refresh(),
                        color: theme.accent1,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: controller.notifications.length,
                          itemBuilder: (context, index) {
                            final notification =
                                controller.notifications[index];
                            return _NotificationCard(
                              notification: notification,
                              onTap: () {
                                // Mark as read when tapped
                                if (notification.isRead == false) {
                                  controller.markAsRead(
                                    notification.notificationId!,
                                  );
                                }
                                _handleNotificationTap(notification);
                              },
                              onDelete: () {
                                controller.deleteNotification(
                                  notification.notificationId!,
                                );
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.bookingRequest:
      case NotificationType.bookingAccepted:
      case NotificationType.bookingRejected:
      case NotificationType.bookingCanceled:
      case NotificationType.bookingCompleted:
        // Navigate to booking details
        final bookingId = notification.data?['bookingId'] as String?;
        if (bookingId != null) {
          // TODO: Navigate to booking details screen
          // Get.to(() => BookingDetailsScreen(bookingId: bookingId));
        }
        break;
      case NotificationType.message:
        // Navigate to chat
        final chatId = notification.data?['chatId'] as String?;
        if (chatId != null) {
          // TODO: Navigate to chat screen
          // Get.to(() => ChatScreen(chatId: chatId));
        }
        break;
      default:
        break;
    }
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  final RxInt unreadCount;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(color: theme.primaryBackground),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: theme.primaryText, size: 24.sp),
          ),
          // Title
          Expanded(
            child: Text(
              'Notifications',
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          // Mark all read button or spacer
          Obx(() {
            if (unreadCount.value > 0) {
              return TextButton(
                onPressed: onMarkAllRead,
                child: Text(
                  'Mark all read',
                  style: theme.bodySmall.copyWith(
                    color: theme.accent1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return SizedBox(width: 48.w); // Spacer to balance the back button
          }),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80.sp,
            color: theme.secondaryText,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Notifications',
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 280.w,
            child: Text(
              'You\'re all caught up! New notifications about your bookings and messages will appear here.',
              textAlign: TextAlign.center,
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isUnread = notification.isRead == false;

    return Dismissible(
      key: Key(notification.notificationId ?? ''),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: theme.error,
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isUnread
                ? theme.accent1.withOpacity(0.1)
                : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isUnread
                  ? theme.accent1.withOpacity(0.3)
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _getIconColor(
                    notification.type,
                    theme,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type, theme),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'Notification',
                            style: theme.bodyLarge.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: theme.accent1,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body ?? '',
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatDate(notification.createdAt),
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType? type) {
    switch (type) {
      case NotificationType.bookingRequest:
      case NotificationType.bookingAccepted:
      case NotificationType.bookingRejected:
      case NotificationType.bookingCanceled:
      case NotificationType.bookingCompleted:
        return Icons.calendar_today;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.system:
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(NotificationType? type, AppTheme theme) {
    switch (type) {
      case NotificationType.bookingRequest:
        return theme.info;
      case NotificationType.bookingAccepted:
      case NotificationType.bookingCompleted:
        return theme.success;
      case NotificationType.bookingRejected:
      case NotificationType.bookingCanceled:
        return theme.error;
      case NotificationType.message:
        return theme.accent1;
      case NotificationType.system:
        return theme.warning;
      default:
        return theme.accent1;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      DateTime dateTime;
      // Handle Firestore Timestamp
      if (timestamp.runtimeType.toString() == 'Timestamp' ||
          timestamp.toString().contains('Timestamp')) {
        // Use dynamic call since we can't import Timestamp directly in this context
        dateTime = (timestamp as dynamic).toDate();
      } else {
        return 'Just now';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, y').format(dateTime);
      }
    } catch (e) {
      return 'Just now';
    }
  }
}
