import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/provider/screens/provider_profile_screen.dart';
import '../features/exchange_messaging_profile/screens/profile_screen.dart';
import '../features/user_discovery/screens/auth/login_screen.dart';
import '../features/user_discovery/screens/role/role_selection_screen.dart';
import '../features/user_discovery/services/user_service.dart';

Widget profileScreenForRole(String? role) => switch (role?.trim().toLowerCase()) {
  'provider' => const ProviderProfileScreen(),
  'player' => const ProfileScreen(),
  null || '' => const RoleSelectionScreen(),
  _ => throw StateError('Unknown account role: $role'),
};

Future<void> openProfile(BuildContext context, {bool retainRoot = false}) async {
  final navigator = Navigator.of(context);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
    return;
  }

  final Widget screen;
  try {
    final role = await UserService().getCurrentUserRole();
    if (!context.mounted) return;
    // Ignore an outdated lookup if the authenticated account changed.
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) return;
    screen = profileScreenForRole(role);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(
        'Unable to load your account role. Please try again.',
      )),
    );
    return;
  }

  final route = MaterialPageRoute<void>(builder: (_) => screen);
  if (screen is RoleSelectionScreen) {
    await navigator.pushAndRemoveUntil(route, (_) => false);
  } else if (retainRoot) {
    await navigator.pushAndRemoveUntil(route, (route) => route.isFirst);
  } else {
    await navigator.push(route);
  }

  // Player Profile pops to the root on logout; Provider Profile redirects itself.
  if (screen is ProfileScreen && navigator.mounted &&
      FirebaseAuth.instance.currentUser == null) {
    // Account deletion already replaced the stack with Create Account.
    // Do not let the existing logout fallback replace that destination.
    var atCreateAccount = false;
    navigator.popUntil((route) {
      atCreateAccount = route.settings.name == '/create-account';
      return true;
    });
    if (atCreateAccount) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
