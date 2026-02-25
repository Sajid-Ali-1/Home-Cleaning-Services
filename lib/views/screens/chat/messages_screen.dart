import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/controllers/bookings_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/models/chat_message.dart';
import 'package:home_cleaning_app/services/chat_db_service.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/chat/chat_screen.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});

  final BookingsController controller = Get.find<BookingsController>();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages', style: theme.displaySmall),
              // SizedBox(height: 4.h),
              // Text(
              //   'Chat with your providers or customers.',
              //   style: theme.bodySmall.copyWith(color: theme.secondaryText),
              // ),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  final chats = controller.bookings
                      .where(
                        (booking) =>
                            booking.status != BookingStatus.canceled &&
                            booking.status != BookingStatus.rejected,
                      )
                      .toList();
                  if (chats.isEmpty) {
                    return Center(
                      child: Text(
                        'No active conversations yet.',
                        style: theme.bodyMedium.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                    );
                  }

                  return _SortedChatList(
                    bookings: chats,
                    isProviderView: controller.isProviderView,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that displays sorted chat list based on last message time
class _SortedChatList extends StatefulWidget {
  const _SortedChatList({required this.bookings, required this.isProviderView});

  final List<BookingModel> bookings;
  final bool isProviderView;

  @override
  State<_SortedChatList> createState() => _SortedChatListState();
}

class _SortedChatListState extends State<_SortedChatList> {
  final Map<String, ChatMessage?> _lastMessages = {};
  final Map<String, StreamSubscription<ChatMessage?>> _subscriptions = {};

  @override
  void initState() {
    super.initState();
    _setupSubscriptions();
  }

  @override
  void didUpdateWidget(_SortedChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookings != widget.bookings) {
      _cleanupSubscriptions();
      _setupSubscriptions();
    }
  }

  @override
  void dispose() {
    _cleanupSubscriptions();
    super.dispose();
  }

  void _setupSubscriptions() {
    for (final booking in widget.bookings) {
      final bookingId = booking.bookingId;
      if (bookingId == null || _subscriptions.containsKey(bookingId)) continue;

      final subscription = ChatDbService.streamLastMessage(bookingId).listen((
        message,
      ) {
        if (mounted) {
          setState(() {
            _lastMessages[bookingId] = message;
          });
        }
      });
      _subscriptions[bookingId] = subscription;
    }
  }

  void _cleanupSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _lastMessages.clear();
  }

  List<BookingModel> get _sortedBookings {
    final sorted = List<BookingModel>.from(widget.bookings);
    sorted.sort((a, b) {
      final aId = a.bookingId ?? '';
      final bId = b.bookingId ?? '';
      final aMessage = _lastMessages[aId];
      final bMessage = _lastMessages[bId];

      // Get timestamps for sorting
      DateTime aTime;
      DateTime bTime;

      if (aMessage != null) {
        aTime = aMessage.createdAt.toDate();
      } else {
        aTime = a.createdAt?.toDate() ?? DateTime(1970);
      }

      if (bMessage != null) {
        bTime = bMessage.createdAt.toDate();
      } else {
        bTime = b.createdAt?.toDate() ?? DateTime(1970);
      }

      // Sort descending (most recent first)
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _sortedBookings.length,
      itemBuilder: (_, index) {
        final booking = _sortedBookings[index];
        return _ChatListTile(
          booking: booking,
          isProviderView: widget.isProviderView,
          lastMessage: _lastMessages[booking.bookingId ?? ''],
        );
      },
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.booking,
    required this.isProviderView,
    this.lastMessage,
  });

  final BookingModel booking;
  final bool isProviderView;
  final ChatMessage? lastMessage;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final participantName = isProviderView
        ? booking.customerName
        : booking.providerName;
    final currentUserId = Get.find<AuthController>().userModel?.uid;
    final hasMessages = lastMessage != null;

    // Determine last message preview
    String lastMessagePreview = 'No messages yet';
    String? lastMessageTime;
    bool isLastMessageFromMe = false;

    if (hasMessages && lastMessage != null) {
      isLastMessageFromMe = lastMessage!.senderId == currentUserId;
      final senderPrefix = isLastMessageFromMe ? 'You: ' : '';

      if (lastMessage!.hasImage) {
        lastMessagePreview = '${senderPrefix}📷 Photo';
      } else if (lastMessage!.text != null && lastMessage!.text!.isNotEmpty) {
        final text = lastMessage!.text!;
        lastMessagePreview =
            senderPrefix +
            (text.length > 40 ? '${text.substring(0, 40)}...' : text);
      } else {
        lastMessagePreview = '${senderPrefix}Message';
      }

      lastMessageTime = _formatRelativeTime(lastMessage!.createdAt);
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      leading: CircleAvatar(
        backgroundColor: theme.accent1.withOpacity(0.15),
        child: Icon(Icons.chat, color: theme.accent1),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              booking.serviceTitle,
              style: theme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessageTime != null) ...[
            SizedBox(width: 8.w),
            Text(
              lastMessageTime,
              style: theme.bodySmall.copyWith(
                color: theme.secondaryText,
                fontSize: 11.sp,
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            participantName ?? 'Conversation',
            style: theme.bodySmall.copyWith(
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasMessages) ...[
            SizedBox(height: 2.h),
            Text(
              lastMessagePreview,
              style: theme.bodySmall.copyWith(
                color: isLastMessageFromMe
                    ? theme.accent1
                    : theme.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: () {
        Get.to(
          () => ChatScreen(booking: booking, isProviderView: isProviderView),
        );
      },
    );
  }

  String _formatRelativeTime(Timestamp timestamp) {
    try {
      final dateTime = timestamp.toDate();
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
        return DateFormat('MMM d').format(dateTime);
      }
    } catch (e) {
      return 'Just now';
    }
  }
}
