import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/exchange_messaging_profile/screens/profile_screen.dart';
import '../features/user_discovery/screens/auth/login_screen.dart';

Future<void> openProfile(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
  );

  if (!context.mounted) return;

  // The existing profile screen pops back to the root after signing out.
  if (FirebaseAuth.instance.currentUser == null) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
