import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Save or update the logged-in user's role
  Future<void> saveUserRole(String role) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    final reference = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction<void>((transaction) async {
      final existing = await transaction.get(reference);
      if (_auth.currentUser?.uid != user.uid) {
        throw StateError('Your login changed. Please select your role again.');
      }
      transaction.set(reference, {
        'uid': user.uid,
        if (!existing.exists) 'name': user.displayName ?? '',
        if (!existing.exists) 'email': user.email ?? '',
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // Get logged-in user's saved role
  Future<String?> getCurrentUserRole() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final Map<String, dynamic>? data = document.data();

    if (data == null) {
      return null;
    }

    return data['role'] as String?;
  }

  // Check whether the user already selected a role
  Future<bool> hasSelectedRole() async {
    final String? role = await getCurrentUserRole();

    return role == 'player' || role == 'provider';
  }
}
