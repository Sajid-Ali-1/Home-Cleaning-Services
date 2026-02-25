import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/chat_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/models/chat_message.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.booking,
    required this.isProviderView,
  });

  final BookingModel booking;
  final bool isProviderView;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatController(booking: widget.booking));
  }

  @override
  void dispose() {
    Get.delete<ChatController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final counterpartName = widget.isProviderView
        ? widget.booking.customerName
        : widget.booking.providerName;
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        iconTheme: IconThemeData(color: theme.primaryText),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              counterpartName ?? 'Conversation',
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              widget.booking.serviceTitle,
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'Start the conversation!',
                    style: theme.bodyMedium.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final message = messages[index];
                  final isMe = message.senderId == controller.currentUserId;
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _MessageBubble(message: message, isMine: isMe),
                  );
                },
              );
            }),
          ),
          _ChatInput(controller: controller),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = isMine ? theme.accent1 : theme.textFieldColor;
    final textColor = isMine ? Colors.white : theme.primaryText;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(12.w),
      constraints: BoxConstraints(maxWidth: 250.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.r).copyWith(
          bottomRight: Radius.circular(isMine ? 4.r : 18.r),
          bottomLeft: Radius.circular(isMine ? 18.r : 4.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                message.imageUrl!,
                height: 160.h,
                width: 220.w,
                fit: BoxFit.cover,
              ),
            ),
          if (message.text != null && message.text!.isNotEmpty) ...[
            SizedBox(height: message.hasImage ? 8.h : 0),
            Text(
              message.text!,
              style: theme.bodyMedium.copyWith(color: textColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Obx(
              () => IconButton(
                icon: controller.isUploading.value
                    ? const CircularProgressIndicator()
                    : Icon(Icons.photo, color: theme.accent1),
                onPressed: controller.isUploading.value
                    ? null
                    : controller.sendImageMessage,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller.textController,
                style: theme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Write a message',
                  hintStyle: theme.bodyMedium.copyWith(
                    color: theme.secondaryText,
                  ),
                  filled: true,
                  fillColor: theme.secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Obx(
              () => IconButton(
                icon: controller.isSending.value
                    ? const CircularProgressIndicator()
                    : Icon(Icons.send, color: theme.accent1),
                onPressed: controller.isSending.value
                    ? null
                    : controller.sendTextMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
