import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SupportService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    throw StateError('Please log in to continue.');
  }

  String get currentUserEmail {
    return _auth.currentUser?.email ?? '';
  }

  Future<String> submitReport({
    required String category,
    required String message,
  }) async {
    final String cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      throw Exception('Please describe your problem.');
    }

    if (cleanMessage.length < 10) {
      throw Exception('Please provide a little more detail.');
    }

    final reference = _firestore.collection('support_reports').doc();

    await reference.set({
      'userId': currentUserId,
      'userEmail': currentUserEmail,
      'category': category,
      'message': cleanMessage,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }
}
