import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary preview user.
    return 'demo_member3_user';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications() {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': currentUserId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> seedDemoNotifications() async {
    final collection = _firestore.collection('notifications');

    await collection.doc('demo_booking_$currentUserId').set({
      'userId': currentUserId,
      'title': 'Booking confirmed',
      'message': 'Your payment was confirmed for SG-1048.',
      'type': 'booking',
      'isRead': false,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    await collection.doc('demo_request_$currentUserId').set({
      'userId': currentUserId,
      'title': 'Request accepted',
      'message': 'Your rental request was accepted.',
      'type': 'request',
      'isRead': true,
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    }, SetOptions(merge: true));

    await collection.doc('demo_payment_$currentUserId').set({
      'userId': currentUserId,
      'title': 'Payment confirmed',
      'message': 'Payment of Rs. 10,400 was successful.',
      'type': 'payment',
      'isRead': true,
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    }, SetOptions(merge: true));

    await collection.doc('demo_return_$currentUserId').set({
      'userId': currentUserId,
      'title': 'Return reminder',
      'message': 'Return your equipment tomorrow.',
      'type': 'return',
      'isRead': true,
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    }, SetOptions(merge: true));
  }
}
