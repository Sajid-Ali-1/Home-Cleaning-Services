import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  ChatMessage({
    required this.messageId,
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.createdAt,
  });

  final String messageId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final Timestamp createdAt;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      messageId: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}

