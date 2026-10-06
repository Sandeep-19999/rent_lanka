import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime? sentAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final Timestamp? timestamp = data['sentAt'] is Timestamp
        ? data['sentAt'] as Timestamp
        : null;

    return MessageModel(
      id: document.id,
      senderId: data['senderId']?.toString() ?? '',
      receiverId: data['receiverId']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      sentAt: timestamp?.toDate(),
      isRead: data['isRead'] == true,
    );
  }
}
