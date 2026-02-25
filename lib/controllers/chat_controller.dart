import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/models/chat_message.dart';
import 'package:home_cleaning_app/models/notification_model.dart';
import 'package:home_cleaning_app/services/notification_service.dart';
import 'package:home_cleaning_app/services/storage_services.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  ChatController({required this.booking});

  final BookingModel booking;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isSending = false.obs;
  final RxBool isUploading = false.obs;
  final TextEditingController textController = TextEditingController();

  late final String _chatId;
  String? _currentUserId;
  StreamSubscription<QuerySnapshot>? _subscription;

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages');

  String? get currentUserId => _currentUserId;

  @override
  void onInit() {
    super.onInit();
    _chatId = booking.bookingId ?? '';
    _currentUserId = Get.find<AuthController>().userModel?.uid;
    if (_chatId.isNotEmpty) {
      _listenToMessages();
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    textController.dispose();
    super.onClose();
  }

  bool get canSend => textController.text.trim().isNotEmpty;

  Future<void> sendTextMessage() async {
    final senderId = _currentUserId;
    if (senderId == null) return;
    final text = textController.text.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await _messagesRef.add({
        'senderId': senderId,
        'text': text,
        'imageUrl': null,
        'createdAt': Timestamp.now(),
      });
      textController.clear();

      // Send notification to the recipient
      await _sendMessageNotification(text: text);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImageMessage() async {
    final senderId = _currentUserId;
    if (senderId == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    isUploading.value = true;
    try {
      final file = File(picked.path);
      final url = await StorageServices.uploadChatImage(
        imageFile: file,
        chatId: _chatId,
        senderId: senderId,
      );
      await _messagesRef.add({
        'senderId': senderId,
        'imageUrl': url,
        'text': null,
        'createdAt': Timestamp.now(),
      });

      // Send notification to the recipient
      await _sendMessageNotification(isImage: true);
    } finally {
      isUploading.value = false;
    }
  }

  void _listenToMessages() {
    _subscription = _messagesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs.map(ChatMessage.fromDocument).toList();
        });
  }

  /// Send notification to the recipient when a new message is sent
  /// Logic:
  /// - If customer sends message → provider receives notification
  /// - If provider sends message → customer receives notification
  Future<void> _sendMessageNotification({
    String? text,
    bool isImage = false,
  }) async {
    try {
      final senderId = _currentUserId;
      if (senderId == null || booking.bookingId == null) {
        print('⚠️ Cannot send notification: missing senderId or bookingId');
        return;
      }

      // Determine recipient (the other person in the chat)
      // If sender is provider → recipient is customer
      // If sender is customer → recipient is provider
      final bool isProvider = senderId == booking.providerId;
      final String recipientId = isProvider
          ? booking.customerId
          : booking.providerId;

      // Safety check: ensure recipient ID is valid
      if (recipientId.isEmpty) {
        print('⚠️ Cannot send notification: recipientId is empty');
        return;
      }

      // Safety check: ensure we're not sending notification to ourselves
      if (recipientId == senderId) {
        print('⚠️ Cannot send notification: recipient is the same as sender');
        return;
      }

      // Get sender's name for the notification
      final senderName = isProvider
          ? (booking.providerName ?? 'Provider')
          : (booking.customerName ?? 'Customer');

      // Create notification title and body
      final title = senderName;
      final body = isImage
          ? 'Sent a photo'
          : (text != null && text.isNotEmpty
                ? (text.length > 50 ? '${text.substring(0, 50)}...' : text)
                : 'New message');

      print(
        '📤 Sending message notification: ${isProvider ? "Provider" : "Customer"} → ${isProvider ? "Customer" : "Provider"}',
      );

      // Send notification with bookingId for proper tap action
      await NotificationService.sendNotificationToUser(
        userId: recipientId,
        title: title,
        body: body,
        type: NotificationType.message,
        data: {
          'bookingId': booking.bookingId!,
          'chatId': booking.bookingId!, // chatId is same as bookingId
          'userId': recipientId,
          'type': NotificationType.message.toJson(),
        },
      );

      print('✅ Message notification sent successfully');
    } catch (e) {
      print('❌ Error sending message notification: $e');
      // Don't throw - fail silently to avoid breaking message sending
    }
  }
}
