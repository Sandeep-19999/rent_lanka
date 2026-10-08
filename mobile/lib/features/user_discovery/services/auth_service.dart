
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CURRENT USER

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // PROVIDER ID - Existing compatibility

  static String get providerId {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    return 'demo_provider';
  }

  // EMAIL + PASSWORD SIGN IN

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // CREATE ACCOUNT AND SAVE FULL NAME

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;

    if (user != null) {
      final String name = fullName?.trim() ?? '';

      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return credential;
  }

  // GOOGLE SIGN IN

  Future<UserCredential> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('email');

    googleProvider.setCustomParameters({
      'prompt': 'select_account',
    });

    return await _auth.signInWithPopup(googleProvider);
  }

  // FORGOT PASSWORD

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // EMAIL VERIFICATION

  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // RELOAD CURRENT USER

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // CHECK EMAIL VERIFICATION

  bool get isEmailVerified {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // AUTH STATE CHANGES

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // SIGN OUT

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
