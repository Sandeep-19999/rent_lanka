import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AccountDeletionService {
  AccountDeletionService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  bool get requiresPassword =>
      _auth.currentUser?.providerData.any(
        (provider) => provider.providerId == 'password',
      ) ??
      false;

  Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');
    // Verify identity before removing any data, even with a recent session.
    if (requiresPassword && user.email != null) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: password ?? '',
        ),
      );
    } else if (user.providerData.any((p) => p.providerId == 'google.com')) {
      final provider = GoogleAuthProvider();
      if (kIsWeb) {
        await user.reauthenticateWithPopup(provider);
      } else {
        await user.reauthenticateWithProvider(provider);
      }
    } else {
      throw FirebaseAuthException(code: 'unsupported-provider');
    }

    final uid = user.uid;
    void checkSession() {
      if (_auth.currentUser?.uid != uid) {
        throw FirebaseAuthException(code: 'user-mismatch');
      }
    }

    checkSession();
    final profile = _firestore.collection('users').doc(uid);
    final snapshot = await profile.get(const GetOptions(source: Source.server));
    if (snapshot.data()?['role']?.toString().toLowerCase() == 'provider') {
      throw FirebaseAuthException(code: 'player-account-required');
    }

    // Explicitly remove known private subcollections: deleting a parent
    // document does not delete its subcollections. Queries are bounded so
    // accounts with many favourites or notifications do not exceed batch limits.
    final queries = <Query<Map<String, dynamic>>>[
      profile.collection('favourites'),
      _firestore.collection('notifications').where('userId', isEqualTo: uid),
      _firestore.collection('support_reports').where('userId', isEqualTo: uid),
      _firestore.collection('reviews').where('reviewerId', isEqualTo: uid),
    ];
    // Preflight access to every collection before the first destructive write.
    for (final query in queries) {
      await query.limit(1).get(const GetOptions(source: Source.server));
    }
    for (final query in queries) {
      while (true) {
        checkSession();
        final page = await query
            .limit(400)
            .get(const GetOptions(source: Source.server));
        if (page.docs.isEmpty) break;
        checkSession();
        final batch = _firestore.batch();
        for (final document in page.docs) {
          batch.delete(document.reference);
        }
        await batch.commit();
      }
    }
    // Keep authentication until Firestore cleanup has succeeded so failures
    // remain retryable. Firebase Auth and Firestore cannot commit atomically.
    checkSession();
    await profile.delete();
    checkSession();
    await user.delete();
  }
}
