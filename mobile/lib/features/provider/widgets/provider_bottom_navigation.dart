import 'package:flutter/material.dart';

import '../../exchange_messaging_profile/screens/messages_screen.dart';
import '../screens/my_listings_screen.dart';
import '../screens/provider_dashboard.dart';
import '../screens/provider_profile_screen.dart';
import '../screens/rental_requests_screen.dart';

class ProviderBottomNavigation extends StatelessWidget {
  const ProviderBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final Widget screen = switch (index) {
      0 => const ProviderDashboard(),
      1 => const MyListingsScreen(),
      2 => const RentalRequestsScreen(),
      3 => const MessagesScreen(),
      _ => const ProviderProfileScreen(),
    };
    final route = MaterialPageRoute<void>(builder: (_) => screen);
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(route, (_) => false);
    } else if (index >= 3 || currentIndex == 0) {
      Navigator.of(context).push(route);
    } else {
      Navigator.of(context).pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFED1235),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.hexagon_outlined), label: 'My Items'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
