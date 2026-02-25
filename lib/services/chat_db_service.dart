import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/chat_message.dart';

class ChatDbService {
  /// Get the last message for a chat (booking)
  static Future<ChatMessage?> getLastMessage(String bookingId) async {
    try {
      if (bookingId.isEmpty) return null;

      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(bookingId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return ChatMessage.fromDocument(query.docs.first);
    } catch (e) {
      print('Error fetching last message: $e');
      return null;
    }
  }

  /// Stream the last message for a chat (booking)
  static Stream<ChatMessage?> streamLastMessage(String bookingId) {
    if (bookingId.isEmpty) {
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(bookingId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return ChatMessage.fromDocument(snapshot.docs.first);
        });
  }
}
