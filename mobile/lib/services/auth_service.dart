import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static String get providerId {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    return 'demo_provider';
  }
}