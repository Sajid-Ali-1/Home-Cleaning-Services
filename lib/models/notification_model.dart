import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  bookingRequest,
  bookingAccepted,
  bookingRejected,
  bookingCanceled,
  bookingCompleted,
  payoutProcessed,
  payoutFailed,
  message,
  system,
  other;

  String toJson() => name;

  static NotificationType? fromJson(String? value) {
    if (value == null) return null;
    try {
      return NotificationType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}

class NotificationModel {
  String? notificationId;
  String? userId; // User who receives the notification
  String? title;
  String? body;
  NotificationType? type;
  bool? isRead;
  Map<String, dynamic>? data; // Additional data (e.g., bookingId, chatId)
  Timestamp? createdAt;

  NotificationModel({
    this.notificationId,
    this.userId,
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.data,
    this.createdAt,
  });

  // Receiving data from server
  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      userId: docData['userId'] as String?,
      title: docData['title'] as String?,
      body: docData['body'] as String?,
      type: NotificationType.fromJson(docData['type'] as String?),
      isRead: docData['isRead'] as bool? ?? false,
      data: docData['data'] != null
          ? Map<String, dynamic>.from(docData['data'] as Map)
          : null,
      createdAt: docData['createdAt'] as Timestamp?,
    );
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type?.toJson(),
      'isRead': isRead ?? false,
      'data': data,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
    Timestamp? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

