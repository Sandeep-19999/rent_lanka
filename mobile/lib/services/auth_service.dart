import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static String get providerId {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary fallback until login/signup is connected
    return 'demo_provider';
  }
}