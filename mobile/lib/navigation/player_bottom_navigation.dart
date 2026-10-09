import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/booking_payment/screens/booking/my_bookings_screen.dart';
import '../features/exchange_messaging_profile/screens/messages_screen.dart';
import '../features/exchange_messaging_profile/screens/profile_screen.dart';
import 'profile_navigation.dart';
import '../features/user_discovery/screens/home/home_screen.dart';
import '../features/user_discovery/screens/search/search_screen.dart';

Widget playerScreenForTab(int index) => switch (index) {
  0 => const HomeScreen(),
  1 => const SearchScreen(),
  2 => const MyBookingsScreen(),
  3 => const MessagesScreen(),
  4 => const ProfileScreen(),
  _ => throw ArgumentError.value(index, 'index', 'Unknown player tab'),
};

Future<void> openPlayerTab(BuildContext context, int index) async {
  final navigator = Navigator.of(context);
  if (index == 0) {
    navigator.popUntil((route) => route.isFirst);
    return;
  }
  if (index == 4) {
    await openProfile(context, retainRoot: true);
    return;
  }
  if (index >= 2 && FirebaseAuth.instance.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to continue.')),
    );
    return;
  }
  // Keep Home and replace every route above it with the selected tab.
  await navigator.pushAndRemoveUntil<void>(
    MaterialPageRoute(builder: (_) => playerScreenForTab(index)),
    (route) => route.isFirst,
  );

}

class PlayerBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final double elevation;

  const PlayerBottomNavigation({
    super.key,
    required this.currentIndex,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) {
      if (index != currentIndex) openPlayerTab(context, index);
    },
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFFED1C24),
    unselectedItemColor: const Color(0xFF999999),
    selectedFontSize: 10,
    unselectedFontSize: 9,
    elevation: elevation,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.download_outlined), label: 'Booking'),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
    ],
  );
}
