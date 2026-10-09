import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static String get providerId {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    throw StateError('Please log in to access your provider account.');
  }

  static String get playerId {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }

    throw StateError('Please log in to access bookings.');
  }

  static String get playerName {
    final User? user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return user?.email?.split('@').first ?? '';
  }

  static bool get isEmailVerified =>
      FirebaseAuth.instance.currentUser?.emailVerified ?? false;
}
