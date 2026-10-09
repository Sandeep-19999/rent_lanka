import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to view notifications.');
    }

    return user.uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyNotifications() {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
  }

  Future<String> createNotification({
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    return createNotificationForUser(
      userId: currentUserId,
      title: title,
      message: message,
      type: type,
      referenceId: referenceId,
    );
  }

  Future<String> createNotificationForUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('Notification user ID is missing.');
    }

    final reference = _firestore.collection('notifications').doc();

    await reference.set({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'referenceId': referenceId ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNotification(
    String notificationId, {
    String? expectedUserId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    final uid = user.uid;
    if (expectedUserId != null && expectedUserId != uid) {
      throw FirebaseAuthException(code: 'user-mismatch');
    }
    if (notificationId.trim().isEmpty || notificationId.contains('/')) {
      throw ArgumentError('Invalid notification ID.');
    }
    final reference = _firestore
        .collection('notifications')
        .doc(notificationId);
    await _firestore.runTransaction<void>((transaction) async {
      final notification = await transaction.get(reference);
      if (_auth.currentUser?.uid != uid) {
        throw FirebaseAuthException(code: 'user-mismatch');
      }
      if (!notification.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'This notification is no longer available.',
        );
      }
      if (notification.data()?['userId'] != uid) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'You can only delete your own notifications.',
        );
      }
      transaction.delete(reference);
    });
  }

  Future<void> seedDemoNotifications() async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    await createNotification(
      title: 'Welcome to Rent Lanka',
      message: 'Your notifications will appear here.',
      type: 'general',
    );
  }
}
