import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SettingsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    throw StateError('Please log in to continue.');
  }

  Stream<bool> watchNotificationPreference() async* {
    yield* _firestore.collection('users').doc(currentUserId).snapshots().map((
      document,
    ) {
      final data = document.data();

      if (data == null) {
        return true;
      }

      return data['notificationsEnabled'] != false;
    });
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    await _firestore.collection('users').doc(currentUserId).set({
      'notificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
