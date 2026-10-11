import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum StartupDestination { onboarding, player, provider, roleSelection }

class StartupSessionService {
  static Future<StartupDestination> restore() async {
    final auth = FirebaseAuth.instance;
    // The first event arrives after Firebase has restored the persisted user.
    final user = await auth.authStateChanges().first.timeout(
      const Duration(seconds: 15),
    );
    if (user == null) return StartupDestination.onboarding;

    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 15));
    if (auth.currentUser?.uid != user.uid) {
      throw StateError('The signed-in account changed during startup.');
    }
    return destinationForRole(profile.data()?['role']?.toString());
  }

  static StartupDestination destinationForRole(String? role) {
    return switch (role?.trim().toLowerCase() ?? '') {
      'player' => StartupDestination.player,
      'provider' => StartupDestination.provider,
      '' => StartupDestination.roleSelection,
      _ => throw StateError(
        'This account role is not supported by the mobile app.',
      ),
    };
  }
}
