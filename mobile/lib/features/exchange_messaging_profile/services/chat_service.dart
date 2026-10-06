import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary preview fallback.
    // When integrated with the real login,
    // Firebase Auth UID will be used automatically.
    return 'demo_member3_user';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String receiverName,
    required String text,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return;
    }

    final chatReference = _firestore.collection('chats').doc(chatId);

    final existingChat = await chatReference.get();

    final chatData = <String, dynamic>{
      'participants': [currentUserId, receiverId],
      'lastMessage': trimmedText,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'otherUserName': receiverName,
    };

    if (!existingChat.exists) {
      chatData['createdAt'] = FieldValue.serverTimestamp();
    }

    await chatReference.set(chatData, SetOptions(merge: true));

    await chatReference.collection('messages').add({
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': trimmedText,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
