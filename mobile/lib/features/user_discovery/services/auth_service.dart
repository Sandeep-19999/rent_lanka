import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================
  // CURRENT USER
  // =========================================================

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // =========================================================
  // PROVIDER ID
  // Keep this for compatibility with the existing
  // Provider module.
  // =========================================================

  static String get providerId {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary fallback until all provider screens
    // are fully connected with Firebase Authentication.
    return 'demo_provider';
  }

  // =========================================================
  // EMAIL + PASSWORD SIGN IN
  // =========================================================

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =========================================================
  // CREATE ACCOUNT
  // =========================================================

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =========================================================
  // GOOGLE SIGN IN
  // Current implementation is for Flutter Web / Chrome.
  // =========================================================

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.addScope('email');

      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      return await _auth.signInWithPopup(
        googleProvider,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =========================================================
  // EMAIL VERIFICATION
  // =========================================================

  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // =========================================================
  // RELOAD CURRENT USER
  // =========================================================

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // =========================================================
  // CHECK EMAIL VERIFICATION
  // =========================================================

  bool get isEmailVerified {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // =========================================================
  // AUTH STATE CHANGES
  // =========================================================

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // =========================================================
  // SIGN OUT
  // =========================================================

  Future<void> signOut() async {
    await _auth.signOut();
  }
}