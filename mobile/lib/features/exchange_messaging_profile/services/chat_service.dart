import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to use messaging.');
    }

    return user.uid;
  }

  String createChatId(String otherUserId) {
    final ids = [currentUserId, otherUserId]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  Future<String> _getCurrentUserName() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 'Rent Lanka User';
    }

    try {
      final document = await _firestore.collection('users').doc(user.uid).get();

      final data = document.data();

      final String name = data?['name']?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        return name;
      }
    } catch (_) {}

    final String displayName = user.displayName?.trim() ?? '';

    if (displayName.isNotEmpty) {
      return displayName;
    }

    final String email = user.email?.trim() ?? '';

    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Rent Lanka User';
  }

  Future<String> getUserDisplayName(String userId) async {
    try {
      final document = await _firestore.collection('users').doc(userId).get();

      final data = document.data();

      final String name = data?['name']?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        return name;
      }

      final String email = data?['email']?.toString().trim() ?? '';

      if (email.isNotEmpty) {
        return email.split('@').first;
      }
    } catch (_) {}

    return 'Provider';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyChats() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  Future<String> ensureChat({
    required String otherUserId,
    required String otherUserName,
  }) async {
    if (otherUserId.isEmpty) {
      throw Exception('User information is missing.');
    }

    if (otherUserId == currentUserId) {
      throw Exception('You cannot create a chat with yourself.');
    }

    final String chatId = createChatId(otherUserId);

    final reference = _firestore.collection('chats').doc(chatId);

    final document = await reference.get();

    final String currentName = await _getCurrentUserName();

    if (!document.exists) {
      await reference.set({
        'participants': [currentUserId, otherUserId],
        'participantNames': {
          currentUserId: currentName,
          otherUserId: otherUserName,
        },
        'unreadCounts': {currentUserId: 0, otherUserId: 0},
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return chatId;
    }

    final data = document.data() ?? {};

    final dynamic rawNames = data['participantNames'];

    final Map<String, dynamic> participantNames = rawNames is Map
        ? Map<String, dynamic>.from(rawNames)
        : <String, dynamic>{};

    participantNames[currentUserId] = currentName;

    participantNames[otherUserId] = otherUserName;

    final dynamic rawCounts = data['unreadCounts'];

    final Map<String, dynamic> unreadCounts = rawCounts is Map
        ? Map<String, dynamic>.from(rawCounts)
        : <String, dynamic>{};

    unreadCounts.putIfAbsent(currentUserId, () => 0);

    unreadCounts.putIfAbsent(otherUserId, () => 0);

    await reference.set({
      'participants': [currentUserId, otherUserId],
      'participantNames': participantNames,
      'unreadCounts': unreadCounts,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String receiverName,
    required String text,
  }) async {
    final String cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    if (receiverId.isEmpty) {
      throw Exception('Receiver information is missing.');
    }

    final String currentName = await _getCurrentUserName();

    final chatReference = _firestore.collection('chats').doc(chatId);

    final messageReference = chatReference.collection('messages').doc();

    await _firestore.runTransaction((transaction) async {
      final chatSnapshot = await transaction.get(chatReference);

      final Map<String, dynamic> chatData = chatSnapshot.data() ?? {};

      final dynamic rawCounts = chatData['unreadCounts'];

      final Map<String, dynamic> unreadCounts = rawCounts is Map
          ? Map<String, dynamic>.from(rawCounts)
          : <String, dynamic>{};

      final int receiverUnread =
          (unreadCounts[receiverId] as num?)?.toInt() ?? 0;

      unreadCounts[receiverId] = receiverUnread + 1;

      unreadCounts.putIfAbsent(currentUserId, () => 0);

      final dynamic rawNames = chatData['participantNames'];

      final Map<String, dynamic> participantNames = rawNames is Map
          ? Map<String, dynamic>.from(rawNames)
          : <String, dynamic>{};

      participantNames[currentUserId] = currentName;

      participantNames[receiverId] = receiverName;

      transaction.set(chatReference, {
        'participants': [currentUserId, receiverId],
        'participantNames': participantNames,
        'unreadCounts': unreadCounts,
        'lastMessage': cleanText,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!chatSnapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(messageReference, {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': cleanText,
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    });

    final NotificationService notificationService = NotificationService(
      firestore: _firestore,
      auth: _auth,
    );

    try {
      await notificationService.createNotificationForUser(
        userId: receiverId,
        title: 'New message from $currentName',
        message: cleanText,
        type: 'message',
        referenceId: chatId,
      );
    } catch (_) {
      // Message was already saved.
      // Notification failure should not send
      // the same message twice.
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    final chatReference = _firestore.collection('chats').doc(chatId);

    final chatDocument = await chatReference.get();

    if (!chatDocument.exists) {
      return;
    }

    final data = chatDocument.data() ?? {};

    final dynamic rawCounts = data['unreadCounts'];

    final Map<String, dynamic> unreadCounts = rawCounts is Map
        ? Map<String, dynamic>.from(rawCounts)
        : <String, dynamic>{};

    unreadCounts[currentUserId] = 0;

    final messages = await chatReference
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    final batch = _firestore.batch();

    batch.update(chatReference, {'unreadCounts': unreadCounts});

    for (final message in messages.docs) {
      if (message.data()['isRead'] != true) {
        batch.update(message.reference, {'isRead': true});
      }
    }

    await batch.commit();
  }
}
