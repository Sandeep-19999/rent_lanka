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

  static String get playerId {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary fallback until login/signup is connected
    return 'demo_player';
  }

  static String get playerName {
    final User? user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'Sports Player';
  }

  static bool get isEmailVerified =>
      FirebaseAuth.instance.currentUser?.emailVerified ?? false;
}
