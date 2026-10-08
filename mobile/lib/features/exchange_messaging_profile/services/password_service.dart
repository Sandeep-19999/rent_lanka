import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  PasswordService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  bool get supportsPassword =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    if (!supportsPassword || user.email == null) {
      throw FirebaseAuthException(code: 'password-provider-required');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      ),
    );
    await user.updatePassword(newPassword);
  }
}
